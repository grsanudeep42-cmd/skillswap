const mongoose = require('mongoose');

const matchSchema = new mongoose.Schema({
  requester: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
  requesterSkillOffered: { type: String, default: '' },
  receiverSkillOffered: { type: String, default: '' },
  message: { type: String, default: '' },
  matchScore: { type: Number, default: 0 },
}, { timestamps: true });

matchSchema.index({ requester: 1, receiver: 1 }, { unique: true });

module.exports = mongoose.model('Match', matchSchema);
