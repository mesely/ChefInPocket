const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

const app = express();
const port = process.env.PORT || 5006;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const contentSectionSchema = new mongoose.Schema(
  {
    key: { type: String, required: true, unique: true },
    homeCategories: [
      {
        title: String,
        emoji: String
      }
    ],
    cuisineOptions: [
      {
        title: String,
        emoji: String
      }
    ],
    quickAccess: [
      {
        title: String,
        subtitle: String,
        iconKey: String,
        routeName: String
      }
    ],
    profileMenu: [
      {
        title: String,
        subtitle: String,
        iconKey: String,
        routeName: String
      }
    ],
    customizationOptions: [
      {
        ingredient: String,
        suggestion: String
      }
    ]
  },
  { timestamps: true }
);

const AppContent = mongoose.model('AppContent', contentSectionSchema);

const savedRecipeSchema = new mongoose.Schema(
  {
    recipeSlug: { type: String, required: true, unique: true },
    title: { type: String, required: true },
    subtitle: String,
    description: String,
    imageUrl: String,
    author: String,
    role: String
  },
  { timestamps: true }
);

const SavedRecipe = mongoose.model('SavedRecipe', savedRecipeSchema);

const starterContent = {
  key: 'bootstrap-content',
  homeCategories: [
    { title: 'Turkish', emoji: '🇹🇷' },
    { title: 'Italian', emoji: '🇮🇹' },
    { title: 'Healthy', emoji: '🥗' },
    { title: 'Quick', emoji: '⚡' }
  ],
  cuisineOptions: [
    { title: 'Turkish', emoji: '🇹🇷' },
    { title: 'Italian', emoji: '🇮🇹' },
    { title: 'Street', emoji: '🥙' },
    { title: 'Vegan', emoji: '🌱' },
    { title: 'Breakfast', emoji: '🍳' },
    { title: 'Soup', emoji: '🍲' },
    { title: 'Salad', emoji: '🥬' },
    { title: 'Dessert', emoji: '🍰' }
  ],
  quickAccess: [
    {
      title: 'Browse Cuisine',
      subtitle: 'Start recipe discovery',
      iconKey: 'explore_outlined',
      routeName: '/browse-cuisine'
    },
    {
      title: 'AI Chat',
      subtitle: 'Ask for help while cooking',
      iconKey: 'auto_awesome_outlined',
      routeName: '/ai-chat'
    },
    {
      title: 'Grocery List',
      subtitle: 'Review missing ingredients',
      iconKey: 'shopping_cart_checkout_outlined',
      routeName: '/grocery-list'
    }
  ],
  profileMenu: [
    {
      title: 'Saved Recipes',
      subtitle: 'Your bookmarked dishes',
      iconKey: 'bookmark_outline',
      routeName: '/saved-recipes'
    },
    {
      title: 'My Recipes',
      subtitle: 'Recipes you have shared',
      iconKey: 'menu_book_outlined',
      routeName: '/my-recipes'
    },
    {
      title: 'Grocery List',
      subtitle: 'Open your missing ingredients',
      iconKey: 'shopping_basket_outlined',
      routeName: '/grocery-list'
    }
  ],
  customizationOptions: [
    {
      ingredient: 'Tomatoes',
      suggestion: 'Replace with roasted peppers for a sweeter finish.'
    },
    {
      ingredient: 'Feta',
      suggestion: 'Swap with white cheese to keep the salty balance.'
    },
    {
      ingredient: 'Chili flakes',
      suggestion: 'Remove if you want a mild family-friendly version.'
    }
  ]
};

async function connectDatabase() {
  await mongoose.connect(process.env.MONGODB_URI, {
    dbName: process.env.DB_NAME || 'chef_in_pocket_content'
  });
}

async function seedContent() {
  await AppContent.updateOne(
    { key: starterContent.key },
    { $set: starterContent },
    { upsert: true }
  );
}

app.get('/health', (_req, res) => {
  res.json({ service: 'content-service', status: 'healthy' });
});

app.get('/bootstrap', async (_req, res) => {
  const content = await AppContent.findOne({ key: starterContent.key }).lean();
  res.json(content || starterContent);
});

app.get('/saved-recipes', async (_req, res) => {
  const recipes = await SavedRecipe.find().sort({ updatedAt: -1 }).lean();
  res.json(recipes);
});

app.post('/saved-recipes', async (req, res) => {
  const { recipeSlug, title, subtitle, description, imageUrl, author, role } = req.body;

  if (!recipeSlug || !title) {
    return res.status(400).json({ message: 'recipeSlug and title are required.' });
  }

  const savedRecipe = await SavedRecipe.findOneAndUpdate(
    { recipeSlug },
    {
      $set: {
        recipeSlug,
        title,
        subtitle,
        description,
        imageUrl,
        author: author || '@selmancooks',
        role: role || 'Saved recipe'
      }
    },
    { new: true, upsert: true }
  ).lean();

  return res.status(201).json({
    message: 'Recipe saved.',
    savedRecipe
  });
});

app.delete('/saved-recipes/:recipeSlug', async (req, res) => {
  const deleted = await SavedRecipe.findOneAndDelete({
    recipeSlug: req.params.recipeSlug
  }).lean();

  if (!deleted) {
    return res.status(404).json({ message: 'Saved recipe not found.' });
  }

  return res.json({
    message: 'Recipe removed from saved.',
    removedRecipeSlug: deleted.recipeSlug
  });
});

async function startServer() {
  try {
    await connectDatabase();
    await seedContent();
    app.listen(port, () => {
      console.log(`Content service is running on port ${port}`);
    });
  } catch (error) {
    console.error('Content service failed to start:', error.message);
    process.exit(1);
  }
}

startServer();
