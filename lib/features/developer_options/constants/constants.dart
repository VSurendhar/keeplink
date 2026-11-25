/// Tags created by "Initialize Database Setup" in Developer Options.
const List<String> seedTagNames = [
  'flutter',
  'dart',
  'mobile',
  'database',
  'tutorial',
];

/// Links created by "Initialize Database Setup" in Developer Options, keyed by
/// the name of their folder: 10 folders with 50 links in total.
///
/// Titles and URLs must be unique, as in the database. The folder sizes vary,
/// and some names and URLs are long, to cover every look of a folder card.
const Map<String, List<({String title, String url})>> seedLinksByFolder = {
  'Flutter Resources': [
    (title: 'Flutter', url: 'https://flutter.dev'),
    (title: 'Dart', url: 'https://dart.dev'),
    (title: 'pub.dev', url: 'https://pub.dev'),
    (title: 'Flutter API', url: 'https://api.flutter.dev'),
    (title: 'Flutter Docs', url: 'https://docs.flutter.dev'),
    (title: 'DartPad', url: 'https://dartpad.dev'),
    (title: 'Bloc', url: 'https://bloclibrary.dev'),
    (title: 'Flutter on GitHub', url: 'https://github.com/flutter/flutter'),
  ],
  'Database Resources': [
    (title: 'Floor', url: 'https://pub.dev/packages/floor'),
    (title: 'SQLite', url: 'https://sqlite.org'),
    (title: 'PostgreSQL', url: 'https://www.postgresql.org'),
    (title: 'MySQL', url: 'https://www.mysql.com'),
    (title: 'MongoDB', url: 'https://www.mongodb.com'),
    (title: 'Redis', url: 'https://redis.io'),
    (title: 'Use The Index, Luke', url: 'https://use-the-index-luke.com'),
    (title: 'DB-Engines', url: 'https://db-engines.com'),
  ],
  'Design Inspiration': [
    (title: 'UX Collective', url: 'https://uxdesign.cc'),
    (title: 'Dribbble', url: 'https://dribbble.com'),
    (title: 'Behance', url: 'https://www.behance.net'),
    (title: 'Mobbin', url: 'https://mobbin.com'),
    (title: 'Awwwards', url: 'https://www.awwwards.com'),
    (title: 'Material Design', url: 'https://m3.material.io'),
    (title: 'Laws of UX', url: 'https://lawsofux.com'),
  ],
  'Articles & Essays': [
    (title: 'Medium', url: 'https://medium.com'),
    (title: 'Paul Graham Essays', url: 'https://paulgraham.com/articles.html'),
    (title: 'Aeon', url: 'https://aeon.co'),
    (title: 'Longreads', url: 'https://longreads.com'),
    (title: 'Martin Fowler', url: 'https://martinfowler.com'),
    (title: 'Wait But Why', url: 'https://waitbutwhy.com'),
  ],
  'Dev & Tools': [
    (title: 'GitHub Blog', url: 'https://github.blog'),
    (title: 'GitHub', url: 'https://github.com'),
    (title: 'Stack Overflow', url: 'https://stackoverflow.com'),
    (title: 'MDN Web Docs', url: 'https://developer.mozilla.org'),
    (title: 'regex101', url: 'https://regex101.com'),
    (title: 'Android Developers', url: 'https://developer.android.com'),
  ],
  'Recipes & Kitchen': [
    (title: 'Kitchen Stories', url: 'https://www.kitchenstories.com'),
    (title: 'Serious Eats', url: 'https://www.seriouseats.com'),
    (title: 'Allrecipes', url: 'https://www.allrecipes.com'),
    (title: 'BBC Good Food', url: 'https://www.bbcgoodfood.com'),
    (title: 'Bon Appetit', url: 'https://www.bonappetit.com'),
  ],
  'Travel & Escapes': [
    (title: 'Lonely Planet', url: 'https://www.lonelyplanet.com'),
    (title: 'Atlas Obscura', url: 'https://www.atlasobscura.com'),
    (title: 'Wikivoyage', url: 'https://www.wikivoyage.org'),
    (title: 'Tripadvisor', url: 'https://www.tripadvisor.com'),
  ],
  'Books, Courses and Learning Resources': [
    (
      title: 'Computer Science on Wikipedia',
      url: 'https://en.wikipedia.org/wiki/Outline_of_computer_science',
    ),
    (title: 'Khan Academy', url: 'https://www.khanacademy.org'),
    (title: 'Project Gutenberg', url: 'https://www.gutenberg.org'),
  ],
  'Architecture': [
    (title: 'ArchDaily', url: 'https://www.archdaily.com'),
    (title: 'Dezeen', url: 'https://www.dezeen.com'),
  ],
  'Music': [(title: 'Bandcamp', url: 'https://bandcamp.com')],
};
