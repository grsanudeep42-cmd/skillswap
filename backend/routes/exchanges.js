const express = require('express');
const Exchange = require('../models/Exchange');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

// GET /api/exchanges
router.get('/', auth, async (req, res) => {
  try {
    const exchanges = await Exchange.find({
      $or: [{ user1: req.user.id }, { user2: req.user.id }],
    })
      .populate('user1', '-password -__v')
      .populate('user2', '-password -__v')
      .populate('match')
      .sort({ updatedAt: -1 });

    res.json({ exchanges });
  } catch (err) {
    console.error('Get exchanges error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/exchanges/:id
router.get('/:id', auth, async (req, res) => {
  try {
    const exchange = await Exchange.findById(req.params.id)
      .populate('user1', '-password -__v')
      .populate('user2', '-password -__v')
      .populate('sessions.loggedBy', 'name')
      .populate('match');

    if (!exchange) {
      return res.status(404).json({ message: 'Exchange not found' });
    }

    const userId = req.user.id;
    if (exchange.user1._id.toString() !== userId && exchange.user2._id.toString() !== userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    res.json({ exchange });
  } catch (err) {
    console.error('Get exchange error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/exchanges/:id/sessions
router.post('/:id/sessions', auth, async (req, res) => {
  try {
    const { duration, notes } = req.body;

    if (!duration || duration <= 0) {
      return res.status(400).json({ message: 'Valid duration is required' });
    }

    const exchange = await Exchange.findById(req.params.id);
    if (!exchange) {
      return res.status(404).json({ message: 'Exchange not found' });
    }

    if (exchange.status !== 'active') {
      return res.status(400).json({ message: 'Exchange is not active' });
    }

    const userId = req.user.id;
    const isUser1 = exchange.user1.toString() === userId;
    const isUser2 = exchange.user2.toString() === userId;

    if (!isUser1 && !isUser2) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    // Add session
    exchange.sessions.push({
      duration,
      notes: notes || '',
      loggedBy: userId,
    });
    exchange.totalSessions = exchange.sessions.length;

    // Update progress (each session adds progress based on target)
    const progressPerSession = 100 / exchange.targetSessions;
    if (isUser1) {
      exchange.user1Progress = Math.min(100, exchange.user1Progress + progressPerSession);
    } else {
      exchange.user2Progress = Math.min(100, exchange.user2Progress + progressPerSession);
    }

    await exchange.save();

    const populated = await Exchange.findById(exchange._id)
      .populate('user1', '-password -__v')
      .populate('user2', '-password -__v')
      .populate('sessions.loggedBy', 'name');

    res.json({ exchange: populated });
  } catch (err) {
    console.error('Log session error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/exchanges/:id/rate
router.post('/:id/rate', auth, async (req, res) => {
  try {
    const { rating, review } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be between 1 and 5' });
    }

    const exchange = await Exchange.findById(req.params.id);
    if (!exchange) {
      return res.status(404).json({ message: 'Exchange not found' });
    }

    const userId = req.user.id;
    const isUser1 = exchange.user1.toString() === userId;
    const isUser2 = exchange.user2.toString() === userId;

    if (!isUser1 && !isUser2) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    // Check if already rated
    const alreadyRated = exchange.ratings.some(r => r.user.toString() === userId);
    if (alreadyRated) {
      return res.status(400).json({ message: 'You have already rated this exchange' });
    }

    exchange.ratings.push({
      user: userId,
      rating,
      review: review || '',
    });

    // Update the OTHER user's rating
    const otherUserId = isUser1 ? exchange.user2 : exchange.user1;
    const otherUser = await User.findById(otherUserId);
    if (otherUser) {
      const totalRatingPoints = otherUser.rating * otherUser.totalRatings + rating;
      otherUser.totalRatings += 1;
      otherUser.rating = Math.round((totalRatingPoints / otherUser.totalRatings) * 10) / 10;
      await otherUser.save();
    }

    // If both users have rated, mark exchange as completed
    if (exchange.ratings.length >= 2) {
      exchange.status = 'completed';
      // Increment completed exchanges for both users
      await User.findByIdAndUpdate(exchange.user1, { $inc: { completedExchanges: 1 } });
      await User.findByIdAndUpdate(exchange.user2, { $inc: { completedExchanges: 1 } });
    }

    await exchange.save();

    const populated = await Exchange.findById(exchange._id)
      .populate('user1', '-password -__v')
      .populate('user2', '-password -__v');

    res.json({ exchange: populated });
  } catch (err) {
    console.error('Rate exchange error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
