const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

const app = express();
const port = process.env.PORT || 5002;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const ingredientSchema = new mongoose.Schema(
  {
    name: String,
    amount: Number,
    unit: String
  },
  { _id: false }
);

const recipeSchema = new mongoose.Schema(
  {
    slug: { type: String, required: true, unique: true },
    title: { type: String, required: true },
    subtitle: String,
    description: String,
    cuisine: String,
    duration: String,
    servings: Number,
    tags: [String],
    ingredientKeys: [String],
    ingredients: [ingredientSchema],
    steps: [String],
    imageUrl: String
  },
  { timestamps: true }
);

const Recipe = mongoose.model('Recipe', recipeSchema);

const starterRecipes = [
  {
    slug: 'menemen',
    title: 'Feta Menemen',
    subtitle: 'Tomatoes, eggs, feta',
    description: 'Tomatoes, onion, eggs, and feta come together in a one-pan skillet that feels fast and comforting.',
    cuisine: 'Turkish',
    duration: '18 min',
    servings: 2,
    tags: ['Turkish', 'Breakfast', 'One pan', 'Easy'],
    ingredientKeys: ['eggs', 'tomato', 'onion', 'oil', 'feta'],
    ingredients: [
      { name: 'Eggs', amount: 3, unit: '' },
      { name: 'Tomatoes', amount: 2, unit: '' },
      { name: 'Onion', amount: 0.5, unit: '' },
      { name: 'Olive Oil', amount: 1, unit: 'tbsp' },
      { name: 'Feta Cheese', amount: 70, unit: 'g' },
      { name: 'Chili Flakes', amount: 0.5, unit: 'tsp' },
      { name: 'Salt', amount: 1, unit: 'pinch' }
    ],
    steps: [
      'Dice the onion finely. Heat olive oil in a non-stick pan over medium heat and cook the onion for 3-4 minutes until soft and translucent.',
      'Chop the tomatoes into small cubes. Add them to the pan with a pinch of salt and chili flakes. Stir and cook for 5-6 minutes until the sauce thickens.',
      'Make small wells in the tomato sauce using a spoon. Crack the eggs into the wells, cover the pan with a lid, and cook for 3-4 minutes until the whites are set but yolks are still slightly runny.',
      'Crumble feta cheese over the top. Remove from heat and serve immediately with crusty bread.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'lentil-soup',
    title: 'Red Lentil Soup',
    subtitle: 'Comforting and nourishing',
    description: 'A warm bowl with red lentils, vegetables, and lemon — a Turkish classic for any day of the week.',
    cuisine: 'Turkish',
    duration: '30 min',
    servings: 4,
    tags: ['Turkish', 'Soup', 'Healthy', 'Budget'],
    ingredientKeys: ['lentils', 'onion', 'carrot', 'water', 'butter'],
    ingredients: [
      { name: 'Red Lentils', amount: 1.5, unit: 'cup' },
      { name: 'Carrot', amount: 1, unit: '' },
      { name: 'Onion', amount: 1, unit: '' },
      { name: 'Garlic', amount: 2, unit: 'cloves' },
      { name: 'Vegetable Stock', amount: 5, unit: 'cups' },
      { name: 'Butter', amount: 1, unit: 'tbsp' },
      { name: 'Cumin', amount: 1, unit: 'tsp' },
      { name: 'Lemon', amount: 1, unit: '' }
    ],
    steps: [
      'Dice the onion and carrot. In a large pot, melt butter over medium heat and sauté the onion for 4 minutes until golden. Add garlic and cook for 1 more minute.',
      'Add the diced carrot, rinsed lentils, and vegetable stock. Bring to a boil, then reduce heat and simmer uncovered for 20 minutes.',
      'Once the lentils are completely soft, use an immersion blender to blend the soup until smooth. Alternatively, transfer in batches to a blender.',
      'Season with cumin, salt, and pepper. Heat the soup through for another 2 minutes.',
      'Serve hot with a squeeze of fresh lemon juice and a drizzle of red pepper butter on top.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'egg-salad',
    title: 'Egg Salad Bowl',
    subtitle: 'Fresh, crisp, and light',
    description: 'A crisp bowl with boiled eggs, greens, cucumber, and a tangy yogurt dressing.',
    cuisine: 'Healthy',
    duration: '12 min',
    servings: 2,
    tags: ['Healthy', 'Fast', 'Lunch', 'Light'],
    ingredientKeys: ['eggs', 'lettuce', 'cucumber', 'yogurt'],
    ingredients: [
      { name: 'Eggs', amount: 2, unit: '' },
      { name: 'Mixed Lettuce', amount: 2, unit: 'cups' },
      { name: 'Cucumber', amount: 1, unit: '' },
      { name: 'Greek Yogurt', amount: 0.5, unit: 'cup' },
      { name: 'Lemon Juice', amount: 1, unit: 'tbsp' },
      { name: 'Olive Oil', amount: 1, unit: 'tsp' },
      { name: 'Salt & Pepper', amount: 1, unit: 'pinch' }
    ],
    steps: [
      'Place eggs in a pot of cold water. Bring to a boil, then cook for exactly 8 minutes for jammy yolks. Transfer immediately to ice water to stop cooking.',
      'While eggs cool, mix Greek yogurt with lemon juice, olive oil, salt, and pepper to make the dressing.',
      'Slice the cucumber into half-moons. Arrange the lettuce leaves in a bowl as the base.',
      'Peel and halve the boiled eggs. Place them on top of the greens along with the cucumber slices.',
      'Drizzle the yogurt dressing generously over the bowl. Finish with a crack of black pepper and serve immediately.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'kisir',
    title: 'Kısır',
    subtitle: 'Bulgur, pomegranate, herbs',
    description: 'A vibrant Turkish bulgur salad with fresh herbs, pomegranate molasses, and crunchy vegetables.',
    cuisine: 'Turkish',
    duration: '20 min',
    servings: 4,
    tags: ['Turkish', 'Salad', 'Vegan', 'Cold'],
    ingredientKeys: ['bulgur', 'tomato', 'onion', 'parsley', 'oil'],
    ingredients: [
      { name: 'Fine Bulgur', amount: 1, unit: 'cup' },
      { name: 'Hot Water', amount: 1, unit: 'cup' },
      { name: 'Tomatoes', amount: 2, unit: '' },
      { name: 'Spring Onions', amount: 4, unit: '' },
      { name: 'Flat Leaf Parsley', amount: 1, unit: 'bunch' },
      { name: 'Pomegranate Molasses', amount: 2, unit: 'tbsp' },
      { name: 'Olive Oil', amount: 3, unit: 'tbsp' },
      { name: 'Tomato Paste', amount: 1, unit: 'tbsp' },
      { name: 'Lemon Juice', amount: 2, unit: 'tbsp' }
    ],
    steps: [
      'Place bulgur in a large bowl. Pour hot water over it, stir in the tomato paste, cover with a plate and let it absorb for 10 minutes.',
      'While the bulgur soaks, finely dice the tomatoes, slice the spring onions, and chop the parsley leaves.',
      'Fluff the bulgur with a fork. It should be soft but not mushy — if water remains, drain it.',
      'Add the chopped vegetables and parsley to the bulgur. Mix well.',
      'Drizzle olive oil, pomegranate molasses, and lemon juice over the mixture. Season generously with salt and pepper.',
      'Toss everything thoroughly, taste, and adjust seasoning. Refrigerate for at least 15 minutes before serving for best flavor.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'kofte',
    title: 'Turkish Köfte',
    subtitle: 'Spiced lamb and beef patties',
    description: 'Juicy grilled meatballs seasoned with cumin, paprika, and onion — a Turkish street food classic.',
    cuisine: 'Turkish',
    duration: '25 min',
    servings: 4,
    tags: ['Turkish', 'Grilled', 'Protein', 'Street Food'],
    ingredientKeys: ['beef', 'onion', 'parsley', 'cumin'],
    ingredients: [
      { name: 'Ground Beef (80% lean)', amount: 400, unit: 'g' },
      { name: 'Ground Lamb', amount: 200, unit: 'g' },
      { name: 'Grated Onion', amount: 1, unit: '' },
      { name: 'Fresh Parsley', amount: 0.5, unit: 'cup' },
      { name: 'Cumin', amount: 1, unit: 'tsp' },
      { name: 'Paprika', amount: 1, unit: 'tsp' },
      { name: 'Salt', amount: 1.5, unit: 'tsp' },
      { name: 'Black Pepper', amount: 0.5, unit: 'tsp' }
    ],
    steps: [
      'Combine ground beef and lamb in a large bowl. Grate the onion directly into the meat to capture all the juice.',
      'Add finely chopped parsley, cumin, paprika, salt, and black pepper. Mix thoroughly with your hands for 2 minutes until the mixture becomes sticky and well combined.',
      'Wet your hands with cold water to prevent sticking. Shape the mixture into oval patties about 8cm long and 2cm thick. You should get 12-14 köfte.',
      'Preheat a grill pan or barbecue to high heat. Cook the köfte for 4-5 minutes per side without pressing down, until nicely charred and cooked through.',
      'Rest for 2 minutes before serving. Serve with flatbread, sliced tomatoes, and a squeeze of lemon.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'coban-salatasi',
    title: 'Çoban Salatası',
    subtitle: 'Tomato, cucumber, herbs',
    description: 'The classic Turkish shepherd salad — simple, crunchy, and refreshing with olive oil and lemon.',
    cuisine: 'Turkish',
    duration: '10 min',
    servings: 2,
    tags: ['Turkish', 'Salad', 'Vegan', 'Fast', 'Fresh'],
    ingredientKeys: ['tomato', 'cucumber', 'onion', 'parsley', 'oil'],
    ingredients: [
      { name: 'Tomatoes', amount: 2, unit: '' },
      { name: 'Cucumber', amount: 1, unit: '' },
      { name: 'Red Onion', amount: 0.5, unit: '' },
      { name: 'Green Pepper', amount: 1, unit: '' },
      { name: 'Fresh Parsley', amount: 0.5, unit: 'cup' },
      { name: 'Olive Oil', amount: 2, unit: 'tbsp' },
      { name: 'Lemon Juice', amount: 1, unit: 'tbsp' },
      { name: 'Salt', amount: 1, unit: 'pinch' }
    ],
    steps: [
      'Dice the tomatoes into small cubes, discarding the seedy center if preferred. Place in a large bowl.',
      'Peel the cucumber and dice into similar-sized pieces as the tomatoes. Add to the bowl.',
      'Finely slice the red onion into half-rings. For a milder flavor, soak in cold water for 5 minutes, then drain.',
      'Slice the green pepper into thin rings. Add the onion and pepper to the bowl.',
      'Finely chop the parsley and add to the salad. Drizzle with olive oil and lemon juice, season with salt.',
      'Toss gently and serve immediately. This salad is best eaten fresh and should not be made too far in advance.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'spaghetti-aglio-olio',
    title: 'Spaghetti Aglio e Olio',
    subtitle: 'Garlic, olive oil, chili',
    description: 'The ultimate Italian pantry pasta — just garlic, good olive oil, chili, and parsley in 15 minutes.',
    cuisine: 'Italian',
    duration: '15 min',
    servings: 2,
    tags: ['Italian', 'Pasta', 'Quick', 'Vegan'],
    ingredientKeys: ['pasta', 'garlic', 'oil', 'parsley'],
    ingredients: [
      { name: 'Spaghetti', amount: 200, unit: 'g' },
      { name: 'Garlic Cloves', amount: 4, unit: '' },
      { name: 'Extra Virgin Olive Oil', amount: 60, unit: 'ml' },
      { name: 'Red Chili Flakes', amount: 1, unit: 'tsp' },
      { name: 'Fresh Parsley', amount: 0.5, unit: 'cup' },
      { name: 'Salt', amount: 1, unit: 'tbsp' },
      { name: 'Parmesan (optional)', amount: 30, unit: 'g' }
    ],
    steps: [
      'Bring a large pot of water to a rolling boil. Add a generous tablespoon of salt — it should taste like the sea. Cook spaghetti according to package instructions until 2 minutes before al dente.',
      'While pasta cooks, thinly slice the garlic cloves. Reserve 1 cup of pasta cooking water before draining.',
      'Heat olive oil in a large pan over medium-low heat. Add garlic and chili flakes. Cook gently for 2-3 minutes, stirring often — the garlic should turn golden, never brown.',
      'Drain the pasta and add it directly to the pan with the garlic oil. Add a splash of pasta water and toss vigorously over high heat for 1-2 minutes.',
      'Remove from heat, add chopped parsley, and toss again. The pasta should be glossy and well-coated. Add more pasta water if too dry. Serve with parmesan if desired.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1551183053-bf91798d047e?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'caprese-salad',
    title: 'Caprese Salad',
    subtitle: 'Mozzarella, tomato, basil',
    description: 'The timeless Italian summer salad — ripe tomatoes, fresh mozzarella, and fragrant basil.',
    cuisine: 'Italian',
    duration: '8 min',
    servings: 2,
    tags: ['Italian', 'Salad', 'Fast', 'Vegetarian', 'Summer'],
    ingredientKeys: ['tomato', 'mozzarella', 'basil', 'oil'],
    ingredients: [
      { name: 'Ripe Tomatoes', amount: 3, unit: '' },
      { name: 'Fresh Mozzarella', amount: 200, unit: 'g' },
      { name: 'Fresh Basil Leaves', amount: 15, unit: '' },
      { name: 'Extra Virgin Olive Oil', amount: 3, unit: 'tbsp' },
      { name: 'Balsamic Glaze', amount: 1, unit: 'tbsp' },
      { name: 'Sea Salt & Black Pepper', amount: 1, unit: 'pinch' }
    ],
    steps: [
      'Slice the tomatoes and mozzarella into even rounds about 1cm thick. Pat the mozzarella dry with paper towels.',
      'Arrange tomato and mozzarella slices alternately in an overlapping pattern on a flat serving plate.',
      'Tuck fresh basil leaves between and around the slices.',
      'Drizzle generously with extra virgin olive oil, then add a light drizzle of balsamic glaze.',
      'Finish with flaky sea salt and cracked black pepper. Serve at room temperature — never cold from the fridge.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1498579150354-977475b7ea0b?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'margherita-pizza',
    title: 'Margherita Pizza',
    subtitle: 'Tomato sauce, mozzarella, basil',
    description: 'A crispy homemade pizza with a tangy tomato base, melted mozzarella, and fresh basil.',
    cuisine: 'Italian',
    duration: '35 min',
    servings: 2,
    tags: ['Italian', 'Pizza', 'Vegetarian', 'Baked'],
    ingredientKeys: ['flour', 'tomato', 'mozzarella', 'basil', 'oil'],
    ingredients: [
      { name: 'Pizza Dough (store-bought)', amount: 250, unit: 'g' },
      { name: 'Passata (tomato sauce)', amount: 0.5, unit: 'cup' },
      { name: 'Fresh Mozzarella', amount: 150, unit: 'g' },
      { name: 'Fresh Basil', amount: 10, unit: 'leaves' },
      { name: 'Olive Oil', amount: 1, unit: 'tbsp' },
      { name: 'Garlic', amount: 1, unit: 'clove' },
      { name: 'Salt & Oregano', amount: 1, unit: 'pinch' }
    ],
    steps: [
      'Preheat your oven to its maximum temperature (250°C / 480°F) with a baking tray or pizza stone inside for at least 30 minutes.',
      'Mix passata with a crushed garlic clove, a pinch of salt, and oregano. This is your sauce — keep it simple.',
      'On a floured surface, stretch the pizza dough by hand into a thin round, about 25cm wide. Try to keep the edges slightly thicker.',
      'Transfer dough to a sheet of baking parchment. Spread the tomato sauce evenly, leaving a 2cm border. Tear mozzarella into chunks and scatter over.',
      'Slide the pizza (with parchment) onto the hot tray. Bake for 8-10 minutes until the crust is golden and cheese is bubbling.',
      'Remove from oven and immediately add fresh basil leaves and a drizzle of olive oil. Slice and serve hot.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'french-omelette',
    title: 'French Omelette',
    subtitle: 'Silky, buttery, perfect',
    description: 'The classic French omelette — pale, rolled, and custardy inside. A simple dish that teaches technique.',
    cuisine: 'French',
    duration: '8 min',
    servings: 1,
    tags: ['French', 'Breakfast', 'Fast', 'Eggs'],
    ingredientKeys: ['eggs', 'butter', 'chives'],
    ingredients: [
      { name: 'Eggs', amount: 3, unit: '' },
      { name: 'Unsalted Butter', amount: 15, unit: 'g' },
      { name: 'Fresh Chives', amount: 1, unit: 'tbsp' },
      { name: 'Salt & White Pepper', amount: 1, unit: 'pinch' }
    ],
    steps: [
      'Crack eggs into a bowl and beat vigorously with a fork until completely uniform — no streaks of white. Season lightly with salt.',
      'Heat a small non-stick pan (20cm) over medium-high heat. Add butter — it should foam but not brown. Swirl to coat the pan.',
      'Pour in the egg mixture. Immediately start stirring rapidly with a silicone spatula, scraping the bottom. After 30 seconds, stop stirring and tilt the pan to spread the runny egg.',
      'When the surface is just barely set (still slightly glossy), add chives in a line across the center.',
      'Tilt the pan at 45 degrees and roll the omelette using the spatula, starting from the far edge. Roll it onto the plate, seam-side down. It should be pale yellow, not browned.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'french-onion-soup',
    title: 'French Onion Soup',
    subtitle: 'Caramelized onions, gruyere',
    description: 'A rich and comforting soup with deeply caramelized onions, beef broth, and a melted gruyere crouton.',
    cuisine: 'French',
    duration: '55 min',
    servings: 4,
    tags: ['French', 'Soup', 'Comfort', 'Winter'],
    ingredientKeys: ['onion', 'butter', 'beef', 'cheese', 'bread'],
    ingredients: [
      { name: 'Large Onions', amount: 4, unit: '' },
      { name: 'Unsalted Butter', amount: 40, unit: 'g' },
      { name: 'Beef Stock', amount: 1, unit: 'liter' },
      { name: 'Dry White Wine', amount: 100, unit: 'ml' },
      { name: 'Baguette Slices', amount: 8, unit: '' },
      { name: 'Gruyere Cheese', amount: 150, unit: 'g' },
      { name: 'Fresh Thyme', amount: 2, unit: 'sprigs' }
    ],
    steps: [
      'Slice all onions into thin half-rings. Melt butter in a heavy pot over medium-low heat. Add onions and a pinch of salt. Cook uncovered for 35-40 minutes, stirring every 5 minutes, until deeply golden and caramelized.',
      'Pour in the white wine and scrape up any fond from the bottom of the pot. Cook for 3 minutes until wine evaporates.',
      'Add beef stock and thyme. Bring to a gentle simmer and cook for 10 minutes. Season with salt and pepper.',
      'Preheat the broiler. Ladle soup into oven-safe bowls. Float 2 baguette slices on top of each bowl.',
      'Top each bowl generously with grated gruyere. Place under the broiler for 3-4 minutes until the cheese is melted, bubbling, and golden in spots. Serve immediately — carefully, the bowls are very hot.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'avocado-toast',
    title: 'Avocado Toast',
    subtitle: 'Sourdough, avocado, egg',
    description: 'Creamy mashed avocado on crispy sourdough with a jammy egg and chili flakes.',
    cuisine: 'Healthy',
    duration: '10 min',
    servings: 2,
    tags: ['Healthy', 'Breakfast', 'Fast', 'Vegan option'],
    ingredientKeys: ['avocado', 'bread', 'eggs', 'lemon'],
    ingredients: [
      { name: 'Ripe Avocados', amount: 2, unit: '' },
      { name: 'Sourdough Bread', amount: 2, unit: 'slices' },
      { name: 'Eggs', amount: 2, unit: '' },
      { name: 'Lemon Juice', amount: 1, unit: 'tbsp' },
      { name: 'Chili Flakes', amount: 0.5, unit: 'tsp' },
      { name: 'Extra Virgin Olive Oil', amount: 1, unit: 'tsp' },
      { name: 'Salt & Black Pepper', amount: 1, unit: 'pinch' }
    ],
    steps: [
      'Bring a pot of water to a gentle simmer. Add a splash of vinegar. Crack eggs into small cups. Swirl the water and gently lower eggs in. Poach for 3 minutes for runny yolks. Remove with a slotted spoon.',
      'Toast the sourdough slices until golden and crispy on both sides.',
      'Halve and scoop the avocados into a bowl. Add lemon juice, salt, and pepper. Mash roughly with a fork — keep it chunky, not completely smooth.',
      'Spread the mashed avocado generously onto the hot toast.',
      'Top each slice with a poached egg. Drizzle with olive oil, sprinkle chili flakes, and add a final pinch of flaky salt. Serve immediately.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'quinoa-bowl',
    title: 'Quinoa Power Bowl',
    subtitle: 'Quinoa, chickpeas, tahini',
    description: 'A nutrient-packed bowl with fluffy quinoa, roasted chickpeas, fresh vegetables, and creamy tahini dressing.',
    cuisine: 'Healthy',
    duration: '25 min',
    servings: 2,
    tags: ['Healthy', 'Vegan', 'Protein', 'Bowl'],
    ingredientKeys: ['quinoa', 'chickpeas', 'cucumber', 'tahini'],
    ingredients: [
      { name: 'Quinoa', amount: 1, unit: 'cup' },
      { name: 'Canned Chickpeas', amount: 1, unit: 'can' },
      { name: 'Cucumber', amount: 1, unit: '' },
      { name: 'Cherry Tomatoes', amount: 1, unit: 'cup' },
      { name: 'Tahini', amount: 3, unit: 'tbsp' },
      { name: 'Lemon Juice', amount: 2, unit: 'tbsp' },
      { name: 'Garlic Powder', amount: 0.5, unit: 'tsp' },
      { name: 'Olive Oil', amount: 2, unit: 'tbsp' }
    ],
    steps: [
      'Rinse quinoa under cold water. Cook in 2 cups of salted water — bring to a boil, cover, and simmer for 15 minutes. Let rest off heat for 5 minutes, then fluff with a fork.',
      'Drain and rinse chickpeas. Pat dry thoroughly. Toss with olive oil, salt, cumin, and paprika. Spread on a baking tray and roast at 200°C for 20 minutes until crispy.',
      'Make the tahini dressing: whisk tahini with lemon juice, garlic powder, 3 tablespoons of water, and salt until smooth. Add more water if too thick.',
      'Dice cucumber and halve cherry tomatoes.',
      'Divide quinoa between bowls. Top with roasted chickpeas, cucumber, and cherry tomatoes. Drizzle generously with tahini dressing and serve.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'protein-omelette',
    title: 'High Protein Omelette',
    subtitle: 'Eggs, cheese, spinach',
    description: 'A dense, satisfying omelette packed with protein from eggs, cottage cheese, and turkey for post-workout meals.',
    cuisine: 'Athlete',
    duration: '10 min',
    servings: 1,
    tags: ['Athlete', 'Protein', 'Breakfast', 'Fast', 'Post-workout'],
    ingredientKeys: ['eggs', 'cheese', 'spinach', 'turkey'],
    ingredients: [
      { name: 'Eggs', amount: 3, unit: '' },
      { name: 'Egg Whites', amount: 2, unit: '' },
      { name: 'Cottage Cheese', amount: 3, unit: 'tbsp' },
      { name: 'Baby Spinach', amount: 1, unit: 'cup' },
      { name: 'Turkey Breast Slices', amount: 60, unit: 'g' },
      { name: 'Salt & Pepper', amount: 1, unit: 'pinch' },
      { name: 'Cooking Spray', amount: 1, unit: 'spray' }
    ],
    steps: [
      'Whisk together whole eggs and egg whites in a bowl. Season with salt and pepper.',
      'Lightly spray a non-stick pan with cooking spray. Heat over medium heat. Add turkey slices and cook for 1 minute.',
      'Add spinach to the pan and stir for 30 seconds until just wilted.',
      'Pour the egg mixture over the turkey and spinach. Let it set for 30 seconds without stirring, then gently lift the edges with a spatula.',
      'Add dollops of cottage cheese across one half of the omelette. Fold the other half over and cook for 1 more minute. Slide onto a plate and serve with fruit on the side.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1612240498936-65f5101365d2?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'greek-yogurt-bowl',
    title: 'Greek Yogurt Protein Bowl',
    subtitle: 'Yogurt, berries, oats, honey',
    description: 'A creamy high-protein breakfast bowl with Greek yogurt, mixed berries, toasted oats, and natural honey.',
    cuisine: 'Athlete',
    duration: '5 min',
    servings: 1,
    tags: ['Athlete', 'Breakfast', 'Fast', 'No cook', 'Recovery'],
    ingredientKeys: ['yogurt', 'berries', 'oats', 'honey'],
    ingredients: [
      { name: 'Full-fat Greek Yogurt', amount: 200, unit: 'g' },
      { name: 'Mixed Berries', amount: 0.5, unit: 'cup' },
      { name: 'Rolled Oats', amount: 3, unit: 'tbsp' },
      { name: 'Honey', amount: 1, unit: 'tbsp' },
      { name: 'Almond Butter', amount: 1, unit: 'tbsp' },
      { name: 'Chia Seeds', amount: 1, unit: 'tsp' },
      { name: 'Cinnamon', amount: 0.25, unit: 'tsp' }
    ],
    steps: [
      'Toast the rolled oats in a dry pan over medium heat for 3-4 minutes, stirring constantly, until golden and nutty-smelling. Set aside to cool.',
      'Spoon the Greek yogurt into a bowl, spreading it to the edges.',
      'Scatter the berries over one side of the yogurt.',
      'Add the toasted oats on the other side. Place a spoonful of almond butter in the center.',
      'Drizzle honey over the entire bowl, sprinkle with chia seeds and cinnamon, and serve immediately for the best texture.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'grilled-chicken-salad',
    title: 'Grilled Chicken Salad',
    subtitle: 'Chicken, mixed greens, lemon',
    description: 'A lean, flavorful grilled chicken over crisp greens with a simple lemon vinaigrette.',
    cuisine: 'Athlete',
    duration: '20 min',
    servings: 1,
    tags: ['Athlete', 'High protein', 'Salad', 'Low carb'],
    ingredientKeys: ['chicken', 'lettuce', 'tomato', 'lemon', 'oil'],
    ingredients: [
      { name: 'Chicken Breast', amount: 180, unit: 'g' },
      { name: 'Mixed Greens', amount: 3, unit: 'cups' },
      { name: 'Cherry Tomatoes', amount: 0.5, unit: 'cup' },
      { name: 'Cucumber', amount: 0.5, unit: '' },
      { name: 'Lemon', amount: 1, unit: '' },
      { name: 'Olive Oil', amount: 1, unit: 'tbsp' },
      { name: 'Dried Oregano', amount: 0.5, unit: 'tsp' },
      { name: 'Salt & Pepper', amount: 1, unit: 'pinch' }
    ],
    steps: [
      'Place the chicken breast between two sheets of cling film and pound to an even thickness of about 1.5cm so it cooks uniformly.',
      'Rub the chicken with olive oil, oregano, salt, and pepper. Let it sit for 5 minutes.',
      'Heat a grill pan over high heat. Cook the chicken for 5-6 minutes per side without moving it, until cooked through with grill marks. Rest on a board for 3 minutes.',
      'Meanwhile, halve the cherry tomatoes and slice the cucumber. Arrange the mixed greens in a bowl.',
      'Slice the rested chicken at an angle across the grain. Arrange over the salad. Squeeze the entire lemon over the top and drizzle with any resting juices. Serve immediately.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'ratatouille',
    title: 'Ratatouille',
    subtitle: 'Roasted Mediterranean vegetables',
    description: 'A vibrant Provençal dish of layered roasted vegetables — courgette, aubergine, tomato, and peppers.',
    cuisine: 'French',
    duration: '50 min',
    servings: 4,
    tags: ['French', 'Vegan', 'Baked', 'Comfort'],
    ingredientKeys: ['tomato', 'zucchini', 'eggplant', 'pepper', 'oil', 'garlic'],
    ingredients: [
      { name: 'Courgette (Zucchini)', amount: 2, unit: '' },
      { name: 'Aubergine (Eggplant)', amount: 1, unit: '' },
      { name: 'Red Pepper', amount: 1, unit: '' },
      { name: 'Tomatoes', amount: 4, unit: '' },
      { name: 'Garlic', amount: 3, unit: 'cloves' },
      { name: 'Olive Oil', amount: 4, unit: 'tbsp' },
      { name: 'Fresh Thyme & Rosemary', amount: 3, unit: 'sprigs' },
      { name: 'Salt & Pepper', amount: 1, unit: 'pinch' }
    ],
    steps: [
      'Preheat the oven to 190°C. Make the sauce: blend 2 tomatoes with 2 garlic cloves, 1 tbsp olive oil, and seasoning. Spread on the bottom of a baking dish.',
      'Slice courgette, aubergine, remaining tomatoes, and red pepper into thin rounds, about 3-4mm thick. Use a sharp knife or mandoline.',
      'Arrange the sliced vegetables in alternating, overlapping circles over the sauce, like a spiral pattern. Place garlic slices between the layers.',
      'Drizzle the remaining olive oil over everything. Season with salt and pepper. Scatter thyme and rosemary on top.',
      'Cover tightly with foil and bake for 40 minutes. Remove foil and bake for a further 10-15 minutes until the vegetables are tender and slightly caramelized.',
      'Let rest for 5 minutes before serving. Excellent warm or at room temperature with crusty bread.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1572453800999-e8d2d1589b7c?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'chickpea-salad',
    title: 'Mediterranean Chickpea Salad',
    subtitle: 'Chickpeas, cucumber, red onion',
    description: 'A protein-rich no-cook salad with chickpeas, fresh vegetables, and a bright lemon-herb dressing.',
    cuisine: 'Healthy',
    duration: '10 min',
    servings: 2,
    tags: ['Healthy', 'Vegan', 'No cook', 'High protein', 'Lunch'],
    ingredientKeys: ['chickpeas', 'cucumber', 'onion', 'tomato', 'parsley', 'lemon'],
    ingredients: [
      { name: 'Canned Chickpeas', amount: 1, unit: 'can' },
      { name: 'Cucumber', amount: 1, unit: '' },
      { name: 'Red Onion', amount: 0.5, unit: '' },
      { name: 'Cherry Tomatoes', amount: 1, unit: 'cup' },
      { name: 'Flat Leaf Parsley', amount: 0.5, unit: 'cup' },
      { name: 'Lemon Juice', amount: 3, unit: 'tbsp' },
      { name: 'Olive Oil', amount: 2, unit: 'tbsp' },
      { name: 'Cumin', amount: 0.5, unit: 'tsp' }
    ],
    steps: [
      'Drain and rinse the chickpeas well under cold water. Shake off excess moisture.',
      'Dice the cucumber into small cubes. Finely slice the red onion. Halve the cherry tomatoes. Roughly chop the parsley.',
      'Combine all the vegetables and chickpeas in a large bowl.',
      'In a small cup, whisk together lemon juice, olive oil, cumin, salt, and pepper.',
      'Pour the dressing over the salad and toss well. Taste and adjust seasoning — it should be bright and lemony. Serve immediately or refrigerate for up to one day.'
    ],
    imageUrl: 'https://images.unsplash.com/photo-1529563021893-cc83c992d75d?auto=format&fit=crop&w=1200&q=80'
  }
];

async function connectDatabase() {
  await mongoose.connect(process.env.MONGODB_URI, {
    dbName: process.env.DB_NAME || 'chef_in_pocket_recipe'
  });
}

async function seedRecipes() {
  await Recipe.bulkWrite(
    starterRecipes.map((recipe) => ({
      updateOne: {
        filter: { slug: recipe.slug },
        update: { $set: recipe },
        upsert: true
      }
    }))
  );
}

const formatAmount = (value) => {
  return value % 1 === 0 ? value.toString() : value.toFixed(1);
};

app.get('/health', (_req, res) => {
  res.json({ service: 'recipe-service', status: 'healthy' });
});

app.get('/', async (_req, res) => {
  const recipes = await Recipe.find().sort({ createdAt: -1 });
  res.json(recipes);
});

app.get('/featured', async (_req, res) => {
  const recipe = await Recipe.findOne().sort({ createdAt: 1 });
  res.json(recipe);
});

app.post('/search-by-ingredients', async (req, res) => {
  const selectedIngredients = (req.body.ingredients || []).map((item) =>
    item.toLowerCase()
  );

  const recipes = await Recipe.find();
  const matches = recipes.filter((recipe) =>
    selectedIngredients.some((ingredient) =>
      recipe.ingredientKeys.includes(ingredient)
    )
  );

  res.json({
    selectedIngredients,
    results: matches
  });
});

app.get('/:slug', async (req, res) => {
  const recipe = await Recipe.findOne({ slug: req.params.slug });
  if (!recipe) {
    return res.status(404).json({ message: 'Recipe not found.' });
  }

  return res.json(recipe);
});

app.post('/:slug/scale', async (req, res) => {
  const recipe = await Recipe.findOne({ slug: req.params.slug });
  if (!recipe) {
    return res.status(404).json({ message: 'Recipe not found.' });
  }

  const servings = Number(req.body.servings || recipe.servings);
  const factor = servings / recipe.servings;

  return res.json({
    title: recipe.title,
    servings,
    scaledIngredients: recipe.ingredients.map((item) => ({
      name: item.name,
      amount: formatAmount(item.amount * factor),
      unit: item.unit
    }))
  });
});

app.post('/:slug/customize', async (req, res) => {
  const recipe = await Recipe.findOne({ slug: req.params.slug });
  if (!recipe) {
    return res.status(404).json({ message: 'Recipe not found.' });
  }

  const replacements = req.body.replacements || [];

  return res.json({
    message: 'Customization applied for preview.',
    recipe: recipe.title,
    replacements
  });
});

app.post('/', async (req, res) => {
  const { title, ingredients, cuisine, prepTime, servings } = req.body;

  if (!title || !ingredients) {
    return res.status(400).json({ message: 'title and ingredients are required.' });
  }

  const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-');
  const ingredientList = String(ingredients)
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);

  const recipe = await Recipe.create({
    slug,
    title,
    subtitle: `${ingredientList.slice(0, 3).join(', ')}`,
    description: `A community recipe shared by one of our chefs.`,
    cuisine: cuisine || 'Custom',
    duration: prepTime ? `${prepTime} min` : '20 min',
    servings: Number(servings || 2),
    tags: ['Community', cuisine || 'Custom'],
    ingredientKeys: ingredientList.map((item) => item.toLowerCase()),
    ingredients: ingredientList.map((item) => ({ name: item, amount: 1, unit: '' })),
    steps: ['Prepare all ingredients.', 'Cook as described in your recipe.', 'Serve and enjoy.'],
    imageUrl:
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=1200&q=80'
  });

  return res.status(201).json({
    message: 'Recipe created successfully.',
    recipe
  });
});

async function startServer() {
  try {
    await connectDatabase();
    await seedRecipes();
    app.listen(port, () => {
      console.log(`Recipe service is running on port ${port}`);
    });
  } catch (error) {
    console.error('Recipe service failed to start:', error.message);
    process.exit(1);
  }
}

startServer();
