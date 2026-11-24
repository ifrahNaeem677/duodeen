// Arabic texts of well-known morning & evening adhkar with simple Urdu meanings.
// Please have these checked by a trusted scholar/book before sharing widely.

class TasbeehItem {
  final String key;
  final String name;
  final String arabic;
  final String urdu;
  const TasbeehItem(this.key, this.name, this.arabic, this.urdu);
}

const tasbeehItems = [
  TasbeehItem('astaghfirullah', 'Astaghfirullah', 'أَسْتَغْفِرُ اللّٰهَ', 'میں اللہ سے معافی مانگتا ہوں'),
  TasbeehItem('subhanallah', 'SubhanAllah', 'سُبْحَانَ اللّٰهِ', 'اللہ پاک ہے'),
  TasbeehItem('alhamdulillah', 'Alhamdulillah', 'اَلْحَمْدُ لِلّٰهِ', 'تمام تعریفیں اللہ کے لیے ہیں'),
];

class Zikr {
  final String id;
  final String title;
  final String arabic;
  final String urdu;
  final int times;
  const Zikr({required this.id, required this.title, required this.arabic, required this.urdu, this.times = 1});
}

const _ayatulKursiArabic =
    'اللّٰهُ لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ';
const _ayatulKursiUrdu =
    'اللہ، اس کے سوا کوئی معبود نہیں، وہ ہمیشہ زندہ اور سب کو قائم رکھنے والا ہے۔ اسے نہ اونگھ آتی ہے نہ نیند۔ آسمانوں اور زمین میں جو کچھ ہے سب اسی کا ہے۔ کون ہے جو اس کی اجازت کے بغیر اس کے پاس سفارش کرے؟ وہ جانتا ہے جو ان کے سامنے ہے اور جو ان کے پیچھے ہے، اور وہ اس کے علم میں سے کسی چیز کا احاطہ نہیں کر سکتے سوائے اس کے جتنا وہ چاہے۔ اس کی کرسی آسمانوں اور زمین پر چھائی ہوئی ہے، ان کی حفاظت اسے نہیں تھکاتی، اور وہ بلند اور عظمت والا ہے۔';

const _sayyidulIstighfarArabic =
    'اللّٰهُمَّ أَنْتَ رَبِّي لَا إِلٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ';
const _sayyidulIstighfarUrdu =
    'اے اللہ! تو میرا رب ہے، تیرے سوا کوئی معبود نہیں۔ تو نے مجھے پیدا کیا اور میں تیرا بندہ ہوں، اور میں اپنی طاقت کے مطابق تیرے عہد اور وعدے پر قائم ہوں۔ میں اپنے کیے کی برائی سے تیری پناہ مانگتا ہوں، مجھ پر تیری نعمتوں کا اقرار کرتا ہوں اور اپنے گناہ کا اعتراف کرتا ہوں، پس مجھے بخش دے، کیونکہ تیرے سوا کوئی گناہوں کو نہیں بخشتا۔';

const _bismillahArabic =
    'بِسْمِ اللّٰهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ';
const _bismillahUrdu =
    'اللہ کے نام سے، جس کے نام کے ساتھ زمین اور آسمان میں کوئی چیز نقصان نہیں پہنچا سکتی، اور وہ سب کچھ سننے والا، جاننے والا ہے۔';

const _hasbiyallahArabic = 'حَسْبِيَ اللّٰهُ لَا إِلٰهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ، وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ';
const _hasbiyallahUrdu = 'مجھے اللہ کافی ہے، اس کے سوا کوئی معبود نہیں، اسی پر میں نے بھروسہ کیا اور وہی عرشِ عظیم کا رب ہے۔';

const _subhanallahWaBihamdihiArabic = 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ';
const _subhanallahWaBihamdihiUrdu = 'اللہ پاک ہے اپنی تعریف کے ساتھ۔';

const morningAzkar = [
  Zikr(id: 'm_kursi', title: 'Ayat al-Kursi', arabic: _ayatulKursiArabic, urdu: _ayatulKursiUrdu),
  Zikr(
    id: 'm_asbahna',
    title: 'Morning Remembrance',
    arabic:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلّٰهِ، وَالْحَمْدُ لِلّٰهِ، لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    urdu: 'ہم نے صبح کی اور اللہ کے سارے ملک نے صبح کی، اور تمام تعریفیں اللہ کے لیے ہیں، اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں۔',
  ),
  Zikr(
    id: 'm_bika',
    title: 'By You We Live',
    arabic: 'اللّٰهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    urdu: 'اے اللہ! تیری ہی مدد سے ہم نے صبح کی اور تیری ہی مدد سے شام کی، تیرے ہی نام سے ہم جیتے اور مرتے ہیں، اور تیری ہی طرف اٹھ کر جانا ہے۔',
  ),
  Zikr(id: 'm_istighfar', title: 'Sayyid al-Istighfar', arabic: _sayyidulIstighfarArabic, urdu: _sayyidulIstighfarUrdu),
  Zikr(id: 'm_bismillah', title: 'Protection', arabic: _bismillahArabic, urdu: _bismillahUrdu, times: 3),
  Zikr(
    id: 'm_raditu',
    title: 'Contentment',
    arabic: 'رَضِيتُ بِاللّٰهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    urdu: 'میں اللہ کے رب ہونے پر، اسلام کے دین ہونے پر اور محمد ﷺ کے نبی ہونے پر راضی ہوں۔',
    times: 3,
  ),
  Zikr(id: 'm_hasbiyallah', title: 'Trust in Allah', arabic: _hasbiyallahArabic, urdu: _hasbiyallahUrdu, times: 7),
  Zikr(
    id: 'm_subhan',
    title: 'Glorification',
    arabic: _subhanallahWaBihamdihiArabic,
    urdu: _subhanallahWaBihamdihiUrdu,
    times: 100,
  ),
];

const eveningAzkar = [
  Zikr(id: 'e_kursi', title: 'Ayat al-Kursi', arabic: _ayatulKursiArabic, urdu: _ayatulKursiUrdu),
  Zikr(
    id: 'e_amsayna',
    title: 'Evening Remembrance',
    arabic:
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلّٰهِ، وَالْحَمْدُ لِلّٰهِ، لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    urdu: 'ہم نے شام کی اور اللہ کے سارے ملک نے شام کی، اور تمام تعریفیں اللہ کے لیے ہیں، اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں۔',
  ),
  Zikr(
    id: 'e_bika',
    title: 'By You We Live',
    arabic: 'اللّٰهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
    urdu: 'اے اللہ! تیری ہی مدد سے ہم نے شام کی اور تیری ہی مدد سے صبح کی، تیرے ہی نام سے ہم جیتے اور مرتے ہیں، اور تیری ہی طرف لوٹ کر جانا ہے۔',
  ),
  Zikr(id: 'e_istighfar', title: 'Sayyid al-Istighfar', arabic: _sayyidulIstighfarArabic, urdu: _sayyidulIstighfarUrdu),
  Zikr(
    id: 'e_audhu',
    title: 'Seeking Refuge',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللّٰهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    urdu: 'میں اللہ کے کامل کلمات کے ذریعے اس کی پیدا کی ہوئی ہر چیز کے شر سے پناہ مانگتا ہوں۔',
    times: 3,
  ),
  Zikr(id: 'e_bismillah', title: 'Protection', arabic: _bismillahArabic, urdu: _bismillahUrdu, times: 3),
  Zikr(id: 'e_hasbiyallah', title: 'Trust in Allah', arabic: _hasbiyallahArabic, urdu: _hasbiyallahUrdu, times: 7),
  Zikr(
    id: 'e_subhan',
    title: 'Glorification',
    arabic: _subhanallahWaBihamdihiArabic,
    urdu: _subhanallahWaBihamdihiUrdu,
    times: 100,
  ),
];

final List<String> morningAzkarIds = morningAzkar.map((z) => z.id).toList();
