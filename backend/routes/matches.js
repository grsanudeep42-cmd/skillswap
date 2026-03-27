const express = require('express');
const User = require('../models/User');
const Match = require('../models/Match');
const Exchange = require('../models/Exchange');
const auth = require('../middleware/auth');

const router = express.Router();

// Matching engine: score = number of bidirectional skill matches * 10
function calculateMatchScore(userA, userB) {
  let score = 0;
  // Skills A wants that B offers
  for (const skill of userA.skillsWanted) {
    if (userB.skillsOffered.some(s => s.toLowerCase() === skill.toLowerCase())) {
      score += 10;
    }
  }
  // Skills B wants that A offers
  for (const skill of userB.skillsWanted) {
    if (userA.skillsOffered.some(s => s.toLowerCase() === skill.toLowerCase())) {
      score += 10;
    }
  }
  return score;
}

// GET /api/matches/suggestions
router.get('/suggestions', auth, async (req, res) => {
  try {
    const currentUser = await User.findById(req.user.id);
    if (!currentUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Get IDs of users already matched with
    const existingMatches = await Match.find({
      $or: [{ requester: req.user.id }, { receiver: req.user.id }],
    }).select('requester receiver');

    const excludeIds = new Set();
    excludeIds.add(req.user.id);
    for (const m of existingMatches) {
      excludeIds.add(m.requester.toString());
      excludeIds.add(m.receiver.toString());
    }

    const potentialUsers = await User.find({
      _id: { $nin: Array.from(excludeIds) },
      skillsOffered: { $exists: true, $ne: [] },
    }).limit(100);

    const suggestions = potentialUsers
      .map(user => {
        const score = calculateMatchScore(currentUser, user);
        return { user: user.toPublicJSON(), matchScore: score };
      })
      .filter(s => s.matchScore > 0)
      .sort((a, b) => b.matchScore - a.matchScore)
      .slice(0, 20);

    res.json({ suggestions });
  } catch (err) {
    console.error('Suggestions error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/matches
router.post('/', auth, async (req, res) => {
  try {
    const { receiverId, requesterSkillOffered, receiverSkillOffered, message } = req.body;

    if (!receiverId) {
      return res.status(400).json({ message: 'Receiver ID is required' });
    }

    if (receiverId === req.user.id) {
      return res.status(400).json({ message: 'Cannot match with yourself' });
    }

    // Check for existing match in either direction
    const existing = await Match.findOne({
      $or: [
        { requester: req.user.id, receiver: receiverId },
        { requester: receiverId, receiver: req.user.id },
      ],
    });
    if (existing) {
      return res.status(400).json({ message: 'Match request already exists' });
    }

    const currentUser = await User.findById(req.user.id);
    const receiverUser = await User.findById(receiverId);
    if (!receiverUser) {
      return res.status(404).json({ message: 'Receiver not found' });
    }

    const matchScore = calculateMatchScore(currentUser, receiverUser);

    const match = await Match.create({
      requester: req.user.id,
      receiver: receiverId,
      requesterSkillOffered: requesterSkillOffered || '',
      receiverSkillOffered: receiverSkillOffered || '',
      message: message || '',
      matchScore,
    });

    const populated = await Match.findById(match._id)
      .populate('requester', '-password -__v')
      .populate('receiver', '-password -__v');

    res.status(201).json({ match: populated });
  } catch (err) {
    console.error('Send match error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/matches
router.get('/', auth, async (req, res) => {
  try {
    const matches = await Match.find({
      $or: [{ requester: req.user.id }, { receiver: req.user.id }],
      status: 'accepted',
    })
      .populate('requester', '-password -__v')
      .populate('receiver', '-password -__v')
      .sort({ updatedAt: -1 });

    res.json({ matches });
  } catch (err) {
    console.error('Get matches error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/matches/pending
router.get('/pending', auth, async (req, res) => {
  try {
    const matches = await Match.find({
      receiver: req.user.id,
      status: 'pending',
    })
      .populate('requester', '-password -__v')
      .populate('receiver', '-password -__v')
      .sort({ createdAt: -1 });

    res.json({ matches });
  } catch (err) {
    console.error('Get pending error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// PUT /api/matches/:id/respond
router.put('/:id/respond', auth, async (req, res) => {
  try {
    const { status } = req.body;
    if (!['accepted', 'rejected'].includes(status)) {
      return res.status(400).json({ message: 'Status must be accepted or rejected' });
    }

    const match = await Match.findById(req.params.id);
    if (!match) {
      return res.status(404).json({ message: 'Match not found' });
    }
    if (match.receiver.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Not authorized to respond to this match' });
    }
    if (match.status !== 'pending') {
      return res.status(400).json({ message: 'Match already responded to' });
    }

    match.status = status;
    await match.save();

    // If accepted, create an Exchange
    if (status === 'accepted') {
      await Exchange.create({
        match: match._id,
        user1: match.requester,
        user2: match.receiver,
        skill1: match.requesterSkillOffered,
        skill2: match.receiverSkillOffered,
      });
    }

    const populated = await Match.findById(match._id)
      .populate('requester', '-password -__v')
      .populate('receiver', '-password -__v');

    res.json({ match: populated });
  } catch (err) {
    console.error('Respond match error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
