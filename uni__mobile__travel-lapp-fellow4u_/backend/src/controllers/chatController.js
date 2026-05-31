const { ChatRoom, Message, User, Booking, Tour } = require('../models');
const { Op } = require('sequelize');

// @desc    Get all chat rooms for current user
// @route   GET /api/chats
// @access  Private
const getChatRooms = async (req, res) => {
  try {
    const userId = req.user.user_id;

    const rooms = await ChatRoom.findAll({
      where: {
        [Op.or]: [
          { participant_one_id: userId },
          { participant_two_id: userId }
        ]
      },
      include: [
        {
          model: User,
          as: 'ParticipantOne',
          attributes: ['user_id', 'first_name', 'last_name', 'avatar_url']
        },
        {
          model: User,
          as: 'ParticipantTwo',
          attributes: ['user_id', 'first_name', 'last_name', 'avatar_url']
        },
        {
          model: Booking,
          include: [{ model: Tour, attributes: ['title'] }]
        }
      ],
      order: [['last_message_at', 'DESC']]
    });

    // Map to identify "Other Participant" for UI
    const formattedRooms = rooms.map(room => {
      const otherParticipant = room.participant_one_id === userId 
        ? room.ParticipantTwo 
        : room.ParticipantOne;
      
      return {
        ...room.toJSON(),
        otherParticipant
      };
    });

    res.json({ success: true, data: formattedRooms });
  } catch (error) {
    console.error('Get Chat Rooms Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get messages for a room
// @route   GET /api/chats/:roomId
// @access  Private
const getChatMessages = async (req, res) => {
  try {
    const { roomId } = req.params;
    const userId = req.user.user_id;

    // Verify user belongs to room
    const room = await ChatRoom.findByPk(roomId);
    if (!room) {
      return res.status(404).json({ success: false, message: 'Chat room not found' });
    }

    if (room.participant_one_id !== userId && room.participant_two_id !== userId) {
      return res.status(403).json({ success: false, message: 'Access denied' });
    }

    const messages = await Message.findAll({
      where: { room_id: roomId },
      include: [
        {
          model: User,
          as: 'Sender',
          attributes: ['user_id', 'first_name', 'last_name', 'avatar_url']
        }
      ],
      order: [['created_at', 'ASC']],
      limit: 50 // In real app, use pagination
    });

    res.json({ success: true, data: messages });
  } catch (error) {
    console.error('Get Chat Messages Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Send a message
// @route   POST /api/chats/:roomId/messages
// @access  Private
const sendMessage = async (req, res) => {
  try {
    const { roomId } = req.params;
    const { content, message_type } = req.body;
    const userId = req.user.user_id;

    const room = await ChatRoom.findByPk(roomId);
    if (!room) {
      return res.status(404).json({ success: false, message: 'Chat room not found' });
    }

    const message = await Message.create({
      room_id: roomId,
      sender_id: userId,
      content,
      message_type: message_type || 'text'
    });

    // NOTE: last_message_preview & last_message_at are updated by DB trigger
    // defined in INITIAL_10_Module_Messaging_System_Schema.sql

    const fullMessage = await Message.findByPk(message.message_id, {
      include: [{ model: User, as: 'Sender', attributes: ['user_id', 'first_name', 'last_name', 'avatar_url'] }]
    });

    res.status(201).json({ success: true, data: fullMessage });
  } catch (error) {
    console.error('Send Message Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Mark messages as read
// @route   PUT /api/chats/:roomId/read
// @access  Private
const markAsRead = async (req, res) => {
  try {
    const { roomId } = req.params;
    const userId = req.user.user_id;

    await Message.update(
      { is_read: true, read_at: new Date() },
      { 
        where: { 
          room_id: roomId, 
          sender_id: { [Op.ne]: userId },
          is_read: false 
        } 
      }
    );

    res.json({ success: true, message: 'Messages marked as read' });
  } catch (error) {
    console.error('Mark As Read Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get or Create room for a booking
// @route   POST /api/chats/init
// @access  Private
const getOrCreateRoom = async (req, res) => {
  try {
    const { booking_id } = req.body;
    const userId = req.user.user_id;

    const booking = await Booking.findByPk(booking_id);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    // Check if room exists
    let room = await ChatRoom.findOne({ where: { booking_id } });

    if (!room) {
      // Create room. In this app, rooms are between Traveler and Guide.
      // If guide not yet assigned, we might need a different logic, but usually chat starts after bid selection.
      if (!booking.guide_id) {
        return res.status(400).json({ success: false, message: 'Guide not assigned to this booking yet' });
      }

      room = await ChatRoom.create({
        booking_id,
        participant_one_id: booking.traveler_id,
        participant_two_id: booking.guide_id,
        last_message_preview: 'Conversation started'
      });
    }

    res.json({ success: true, data: room });
  } catch (error) {
    console.error('Init Chat Room Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getChatRooms,
  getChatMessages,
  sendMessage,
  markAsRead,
  getOrCreateRoom
};
