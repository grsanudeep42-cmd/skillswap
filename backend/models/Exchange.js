const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema({
  duration: { type: Number, required: true },
  notes: { type: String, default: '' },
  loggedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
}, { timestamps: true });

const ratingSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  rating: { type: Number, required: true, min: 1, max: 5 },
  review: { type: String, default: '' },
}, { timestamps: true });

const exchangeSchema = new mongoose.Schema({
  match: { type: mongoose.Schema.Types.ObjectId, ref: 'Match', required: true },
  user1: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  user2: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  skill1: { type: String, default: '' },
  skill2: { type: String, default: '' },
  user1Progress: { type: Number, default: 0 },
  user2Progress: { type: Number, default: 0 },
  totalSessions: { type: Number, default: 0 },
  targetSessions: { type: Number, default: 10 },
  sessions: [sessionSchema],
  ratings: [ratingSchema],
  status: { type: String, enum: ['active', 'completed', 'cancelled'], default: 'active' },
}, { timestamps: true });

module.exports = mongoose.model('Exchange', exchangeSchema);
