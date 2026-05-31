const sequelize = require('../config/database');
const User = require('./User');
const Country = require('./Country');
const SocialAccount = require('./SocialAccount');
const PasswordReset = require('./PasswordReset');
const Location = require('./Location');
const GuideProfile = require('./GuideProfile');
const Tour = require('./Tour');
const Experience = require('./Experience');
const TravelNews = require('./TravelNews');
const Wishlist = require('./Wishlist');
const Language = require('./Language');
const GuidePricing = require('./GuidePricing');
const Review = require('./Review');
const Attraction = require('./Attraction');
const PortfolioMedia = require('./PortfolioMedia');
const TourProvider = require('./TourProvider');
const TourImage = require('./TourImage');
const TourSchedule = require('./TourSchedule');
const TourAgePricing = require('./TourAgePricing');
const GuideAvailability = require('./GuideAvailability');
const SearchHistory = require('./SearchHistory');
const AppBanner = require('./AppBanner');
const Collection = require('./Collection');
const CollectionGuide = require('./CollectionGuide');
const CollectionTour = require('./CollectionTour');
const Booking = require('./Booking');
const BookingBid = require('./BookingBid');
const BookingStatusHistory = require('./BookingStatusHistory');
const Payment = require('./Payment');
const UserPaymentMethod = require('./UserPaymentMethod');
const RefundRequest = require('./RefundRequest');
const ChatRoom = require('./ChatRoom');
const Message = require('./Message');
const Notification = require('./Notification')(sequelize);
const NotificationTemplate = require('./NotificationTemplate')(sequelize);

// Module 12 Models
const SecurityLog = require('./SecurityLog');
const UserPhoto = require('./UserPhoto');
const UserJourney = require('./UserJourney');
const JourneyMedia = require('./JourneyMedia');
const UserSetting = require('./UserSetting');


// Associations - Module 1
User.belongsTo(Country, { foreignKey: 'country_id' });
Country.hasMany(User, { foreignKey: 'country_id' });

User.hasMany(SocialAccount, { foreignKey: 'user_id' });
SocialAccount.belongsTo(User, { foreignKey: 'user_id' });

// Associations - Module 2
Location.belongsTo(Country, { foreignKey: 'country_id' });
Country.hasMany(Location, { foreignKey: 'country_id' });

User.hasOne(GuideProfile, { foreignKey: 'guide_id' });
GuideProfile.belongsTo(User, { foreignKey: 'guide_id' });

GuideProfile.belongsTo(Location, { foreignKey: 'base_location_id', as: 'BaseLocation' });

Tour.belongsTo(Location, { foreignKey: 'location_id' });
Location.hasMany(Tour, { foreignKey: 'location_id' });

Experience.belongsTo(GuideProfile, { foreignKey: 'guide_id' });
GuideProfile.hasMany(Experience, { foreignKey: 'guide_id' });

Experience.belongsTo(Location, { foreignKey: 'location_id' });
Location.hasMany(Experience, { foreignKey: 'location_id' });

Wishlist.belongsTo(User, { foreignKey: 'user_id' });
Wishlist.belongsTo(Tour, { foreignKey: 'tour_id' });
Wishlist.belongsTo(Experience, { foreignKey: 'exp_id' });

// Associations - Module 3 (Service & Destination Detail)
GuideProfile.hasMany(GuidePricing, { foreignKey: 'guide_id', as: 'Pricings' });
GuidePricing.belongsTo(GuideProfile, { foreignKey: 'guide_id' });

GuideProfile.hasMany(Review, { foreignKey: 'guide_id', as: 'Reviews' });
Review.belongsTo(GuideProfile, { foreignKey: 'guide_id' });
Review.belongsTo(User, { foreignKey: 'author_id', as: 'Author' });

GuideProfile.hasMany(PortfolioMedia, { foreignKey: 'guide_id', as: 'Portfolio' });
PortfolioMedia.belongsTo(GuideProfile, { foreignKey: 'guide_id' });

GuideProfile.belongsToMany(Language, { 
  through: 'guide_languages', 
  foreignKey: 'guide_id', 
  otherKey: 'lang_id',
  timestamps: false 
});
Language.belongsToMany(GuideProfile, { 
  through: 'guide_languages', 
  foreignKey: 'lang_id', 
  otherKey: 'guide_id',
  timestamps: false 
});

Location.hasMany(Attraction, { foreignKey: 'location_id', as: 'Attractions' });
Attraction.belongsTo(Location, { foreignKey: 'location_id' });

// Associations - Module 4 (Tour Details)
Tour.belongsTo(TourProvider, { foreignKey: 'provider_id', as: 'Provider' });
TourProvider.hasMany(Tour, { foreignKey: 'provider_id' });

Tour.hasMany(TourImage, { foreignKey: 'tour_id', as: 'Images' });
TourImage.belongsTo(Tour, { foreignKey: 'tour_id' });

Tour.hasMany(TourSchedule, { foreignKey: 'tour_id', as: 'Schedules' });
TourSchedule.belongsTo(Tour, { foreignKey: 'tour_id' });
TourSchedule.belongsTo(Attraction, { foreignKey: 'attraction_id' });

Tour.hasMany(TourAgePricing, { foreignKey: 'tour_id', as: 'AgePricings' });
TourAgePricing.belongsTo(Tour, { foreignKey: 'tour_id' });

// Associations - Module 5 (Search & Filtering)
GuideProfile.hasMany(GuideAvailability, { foreignKey: 'guide_id', as: 'Availability' });
GuideAvailability.belongsTo(GuideProfile, { foreignKey: 'guide_id' });

User.hasMany(SearchHistory, { foreignKey: 'user_id' });
SearchHistory.belongsTo(User, { foreignKey: 'user_id' });

// Associations - Module 6 (Categories & Extended View)
Collection.belongsToMany(GuideProfile, { 
  through: CollectionGuide, 
  foreignKey: 'collection_id', 
  otherKey: 'guide_id',
  as: 'Guides'
});
GuideProfile.belongsToMany(Collection, { 
  through: CollectionGuide, 
  foreignKey: 'guide_id', 
  otherKey: 'collection_id' 
});

Collection.belongsToMany(Tour, { 
  through: CollectionTour, 
  foreignKey: 'collection_id', 
  otherKey: 'tour_id',
  as: 'Tours'
});
Tour.belongsToMany(Collection, { 
  through: CollectionTour, 
  foreignKey: 'tour_id', 
  otherKey: 'collection_id' 
});

// Associations - Module 7 (Trip Management & Workflow)
User.hasMany(Booking, { foreignKey: 'traveler_id', as: 'TravelerBookings' });
Booking.belongsTo(User, { foreignKey: 'traveler_id', as: 'Traveler' });

GuideProfile.hasMany(Booking, { foreignKey: 'guide_id', as: 'GuideBookings' });
Booking.belongsTo(GuideProfile, { foreignKey: 'guide_id', as: 'Guide' });

Tour.hasMany(Booking, { foreignKey: 'tour_id' });
Booking.belongsTo(Tour, { foreignKey: 'tour_id' });

Booking.hasMany(BookingBid, { foreignKey: 'booking_id', as: 'Bids' });
BookingBid.belongsTo(Booking, { foreignKey: 'booking_id' });

BookingBid.belongsTo(GuideProfile, { foreignKey: 'guide_id', as: 'Guide' });
GuideProfile.hasMany(BookingBid, { foreignKey: 'guide_id' });

Booking.hasMany(BookingStatusHistory, { foreignKey: 'booking_id', as: 'StatusHistory' });
BookingStatusHistory.belongsTo(Booking, { foreignKey: 'booking_id' });

// Associations - Module 9 (Payment & Checkout)
User.hasMany(UserPaymentMethod, { foreignKey: 'user_id', as: 'PaymentMethods' });
UserPaymentMethod.belongsTo(User, { foreignKey: 'user_id' });

Booking.hasMany(Payment, { foreignKey: 'booking_id', as: 'Payments' });
Payment.belongsTo(Booking, { foreignKey: 'booking_id' });

User.hasMany(Payment, { foreignKey: 'user_id', as: 'UserPayments' });
Payment.belongsTo(User, { foreignKey: 'user_id' });

Payment.hasMany(RefundRequest, { foreignKey: 'payment_id', as: 'Refunds' });
RefundRequest.belongsTo(Payment, { foreignKey: 'payment_id' });

// Associations - Module 10 (Messaging System)
ChatRoom.belongsTo(Booking, { foreignKey: 'booking_id' });
Booking.hasOne(ChatRoom, { foreignKey: 'booking_id' });

ChatRoom.belongsTo(User, { foreignKey: 'participant_one_id', as: 'ParticipantOne' });
ChatRoom.belongsTo(User, { foreignKey: 'participant_two_id', as: 'ParticipantTwo' });

ChatRoom.hasMany(Message, { foreignKey: 'room_id', as: 'Messages' });
Message.belongsTo(ChatRoom, { foreignKey: 'room_id' });

Message.belongsTo(User, { foreignKey: 'sender_id', as: 'Sender' });
User.hasMany(Message, { foreignKey: 'sender_id' });

// Associations - Module 11 (Notification Center)
User.hasMany(Notification, { foreignKey: 'user_id', as: 'Notifications' });
Notification.belongsTo(User, { foreignKey: 'user_id' });

// Associations - Module 12 (Profile & Personal Media)
User.hasMany(UserPhoto, { foreignKey: 'user_id', as: 'Photos' });
UserPhoto.belongsTo(User, { foreignKey: 'user_id' });

User.hasMany(UserJourney, { foreignKey: 'user_id', as: 'Journeys' });
UserJourney.belongsTo(User, { foreignKey: 'user_id' });

User.hasOne(UserSetting, { foreignKey: 'user_id', as: 'Settings' });
UserSetting.belongsTo(User, { foreignKey: 'user_id' });

User.hasMany(SecurityLog, { foreignKey: 'user_id', as: 'SecurityLogs' });
SecurityLog.belongsTo(User, { foreignKey: 'user_id' });

UserJourney.belongsToMany(UserPhoto, { 
  through: JourneyMedia, 
  foreignKey: 'journey_id', 
  otherKey: 'photo_id',
  as: 'Media'
});
UserPhoto.belongsToMany(UserJourney, { 
  through: JourneyMedia, 
  foreignKey: 'photo_id', 
  otherKey: 'journey_id' 
});


module.exports = {
  sequelize,
  User,
  Country,
  SocialAccount,
  PasswordReset,
  Location,
  GuideProfile,
  Tour,
  Experience,
  TravelNews,
  Wishlist,
  Language,
  GuidePricing,
  Review,
  Attraction,
  PortfolioMedia,
  TourProvider,
  TourImage,
  TourSchedule,
  TourAgePricing,
  GuideAvailability,
  SearchHistory,
  AppBanner,
  Collection,
  CollectionGuide,
  CollectionTour,
  Booking,
  BookingBid,
  BookingStatusHistory,
  ChatRoom,
  Message,
  Notification,
  NotificationTemplate,
  UserPhoto,
  UserJourney,
  UserSetting,
  SecurityLog,
  JourneyMedia,
  Payment,
  UserPaymentMethod,
  RefundRequest
};
