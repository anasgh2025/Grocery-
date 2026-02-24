const mongoose = require('mongoose');

// ── Schema ──────────────────────────────────────────────────────────────
const marketingCardSchema = new mongoose.Schema({
  id:       { type: String, required: true, unique: true },
  title:    { type: String, required: true },
  subtitle: { type: String, required: true },
  imageUrl: { type: String, default: '/assets/images/bk.png' },
  order:    { type: Number, default: 0 },
}, { timestamps: true });

const MarketingCard = mongoose.model('MarketingCard', marketingCardSchema);

// ── Helpers ─────────────────────────────────────────────────────────────
const toPlain = (doc) => {
  if (!doc) return null;
  const obj = doc.toObject();
  delete obj._id;
  delete obj.__v;
  delete obj.createdAt;
  delete obj.updatedAt;
  return obj;
};

// ── Default cards to seed when collection is empty ──────────────────────
const defaultCards = [
  {
    id: '1',
    title: 'Fresh Organic Produce',
    subtitle: 'Get 20% off on all organic vegetables',
    imageUrl: '/assets/images/bk.png',
    order: 1,
  },
  {
    id: '2',
    title: 'Weekly Meal Deals',
    subtitle: 'Save big on family meal bundles',
    imageUrl: '/assets/images/bk.png',
    order: 2,
  },
];

// Seed default cards if collection is empty (called once at startup)
const seedDefaults = async () => {
  const count = await MarketingCard.countDocuments();
  if (count === 0) {
    await MarketingCard.insertMany(defaultCards);
    console.log('🎯 Seeded default marketing cards');
  }
};

// ── CRUD ────────────────────────────────────────────────────────────────
const getAll = async () => {
  const docs = await MarketingCard.find().sort({ order: 1 }).lean();
  return docs.map(({ _id, __v, createdAt, updatedAt, ...rest }) => rest);
};

const getById = async (id) => {
  const doc = await MarketingCard.findOne({ id });
  return doc ? toPlain(doc) : null;
};

const create = async (cardData) => {
  const doc = await MarketingCard.create(cardData);
  return toPlain(doc);
};

const update = async (id, cardData) => {
  const existing = await MarketingCard.findOne({ id });
  if (!existing) return null;

  existing.title = cardData.title !== undefined ? cardData.title : existing.title;
  existing.subtitle = cardData.subtitle !== undefined ? cardData.subtitle : existing.subtitle;
  existing.imageUrl = cardData.imageUrl !== undefined ? cardData.imageUrl : existing.imageUrl;
  existing.order = cardData.order !== undefined ? cardData.order : existing.order;

  await existing.save();
  return toPlain(existing);
};

const remove = async (id) => {
  const result = await MarketingCard.deleteOne({ id });
  return result.deletedCount > 0;
};

const reset = async () => {
  await MarketingCard.deleteMany({});
  await MarketingCard.insertMany(defaultCards);
};

module.exports = {
  getAll,
  getById,
  create,
  update,
  remove,
  reset,
  seedDefaults,
  MarketingCard,
};
