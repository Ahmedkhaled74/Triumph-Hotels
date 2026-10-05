import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _dict = {
    'Home': {
      'ar': 'الرئيسية', 'es': 'Inicio', 'fr': 'Accueil', 'de': 'Startseite',
      'ru': 'Главная', 'zh': '首页', 'ja': 'ホーム'
    },
    'All': {
      'ar': 'الكل', 'es': 'Todos', 'fr': 'Tout', 'de': 'Alle',
      'ru': 'Все', 'zh': '全部', 'ja': 'すべて'
    },
    'Attraction': {
      'ar': 'معلم سياحي', 'es': 'Atracción', 'fr': 'Attraction', 'de': 'Attraktion',
      'ru': 'Достопримечательность', 'zh': '景点', 'ja': '観光名所'
    },
    'Shopping': {
      'ar': 'تسوق', 'es': 'Compras', 'fr': 'Shopping', 'de': 'Einkaufen',
      'ru': 'Шопинг', 'zh': '购物', 'ja': 'ショッピング'
    },
    'Food': {
      'ar': 'طعام', 'es': 'Comida', 'fr': 'Nourriture', 'de': 'Essen',
      'ru': 'Еда', 'zh': '美食', 'ja': '食べ物'
    },
    'Museum': {
      'ar': 'متحف', 'es': 'Museo', 'fr': 'Musée', 'de': 'Museum',
      'ru': 'Музей', 'zh': '博物馆', 'ja': '博物館'
    },
    'Park': {
      'ar': 'حديقة', 'es': 'Parque', 'fr': 'Parc', 'de': 'Park',
      'ru': 'Парк', 'zh': '公园', 'ja': '公園'
    },
    'Cafe': {
      'ar': 'مقهى', 'es': 'Cafetería', 'fr': 'Café', 'de': 'Café',
      'ru': 'Кафе', 'zh': '咖啡馆', 'ja': 'カフェ'
    },
    'Nightlife': {
      'ar': 'حياة ليلية', 'es': 'Vida nocturna', 'fr': 'Vie nocturne', 'de': 'Nachtleben',
      'ru': 'Ночная жизнь', 'zh': '夜生活', 'ja': 'ナイトライフ'
    },
    'Other': {
      'ar': 'أخرى', 'es': 'Otro', 'fr': 'Autre', 'de': 'Andere',
      'ru': 'Другое', 'zh': '其他', 'ja': 'その他'
    },
    'Coming Soon': {
      'ar': 'قريباً', 'es': 'Próximamente', 'fr': 'Bientôt disponible', 'de': 'Demnächst',
      'ru': 'Скоро', 'zh': '即将推出', 'ja': '近日公開'
    },
    'Requesting:': {
      'ar': 'طلب:', 'es': 'Solicitando:', 'fr': 'Demande de :', 'de': 'Anfrage:',
      'ru': 'Запрос:', 'zh': '请求：', 'ja': 'リクエスト:'
    },
    'Unknown Place': {
      'ar': 'مكان غير معروف', 'es': 'Lugar desconocido', 'fr': 'Lieu inconnu', 'de': 'Unbekannter Ort',
      'ru': 'Неизвестное место', 'zh': '未知地点', 'ja': '不明な場所'
    },
    'Venue': {
      'ar': 'مكان', 'es': 'Lugar', 'fr': 'Lieu', 'de': 'Veranstaltungsort',
      'ru': 'Место проведения', 'zh': '场地', 'ja': '会場'
    },
    'Enjoy our finest dining experience.': {
      'ar': 'استمتع بأرقى تجربة لتناول الطعام.', 'es': 'Disfrute de nuestra mejor experiencia gastronómica.', 'fr': 'Profitez de notre meilleure expérience gastronomique.', 'de': 'Genießen Sie unser feinstes kulinarisches Erlebnis.',
      'ru': 'Наслаждайтесь нашим лучшим кулинарным опытом.', 'zh': '享受我们最顶级的餐饮体验。', 'ja': '最高のダイニング体験をお楽しみください。'
    },
    'a hotel amenity that working 24/7 allowing...': {
      'ar': 'من وسائل الراحة في الفندق التي تعمل على مدار الساعة...', 'es': 'una comodidad del hotel que funciona 24/7 permitiendo...', 'fr': 'une commodité de l\'hôtel fonctionnant 24/7 permettant...', 'de': 'eine Hotelannehmlichkeit, die 24/7 funktioniert und ermöglicht...',
      'ru': 'удобство отеля, работающее круглосуточно, позволяющее...', 'zh': '一个 24/7 工作的酒店设施，允许...', 'ja': '24時間年中無休で利用できるホテルの設備で...'
    },
    'Requests': {
      'ar': 'الطلبات', 'es': 'Solicitudes', 'fr': 'Demandes', 'de': 'Anfragen',
      'ru': 'Запросы', 'zh': '请求', 'ja': 'リクエスト'
    },
    'Dining': {
      'ar': 'الطعام', 'es': 'Comida', 'fr': 'Restauration', 'de': 'Essen',
      'ru': 'Рестораны', 'zh': '餐饮', 'ja': 'ダイニング'
    },
    'Dining & Cafes': {
      'ar': 'مطاعم ومقاهي', 'es': 'Comedor y Cafés', 'fr': 'Restauration & Cafés', 'de': 'Essen & Cafés',
      'ru': 'Рестораны и Кафе', 'zh': '餐饮与咖啡', 'ja': 'ダイニング＆カフェ'
    },
    'Laundry': {
      'ar': 'غسيل الملابس', 'es': 'Lavandería', 'fr': 'Blanchisserie', 'de': 'Wäsche',
      'ru': 'Прачечная', 'zh': '洗衣', 'ja': 'ランドリー'
    },
    'Transport': {
      'ar': 'النقل', 'es': 'Transporte', 'fr': 'Transport', 'de': 'Transport',
      'ru': 'Транспорт', 'zh': '交通', 'ja': '交通'
    },
    'Discover': {
      'ar': 'اكتشف', 'es': 'Descubrir', 'fr': 'Découvrir', 'de': 'Entdecken',
      'ru': 'Откройте для себя', 'zh': '发现', 'ja': '発見'
    },
    'How can we help?': {
      'ar': 'كيف يمكننا مساعدتك؟', 'es': '¿Cómo podemos ayudar?', 'fr': 'Comment pouvons-nous vous aider?', 'de': 'Wie können wir helfen?',
      'ru': 'Чем мы можем помочь?', 'zh': '我们能怎么帮助您？', 'ja': 'どのようにお手伝いしましょうか？'
    },
    'Let us know what you need, and we\'ll handle the rest.': {
      'ar': 'أخبرنا بما تحتاجه وسنتكفل بالباقي.', 'es': 'Déjenos saber lo que necesita y nos encargaremos del resto.', 'fr': 'Faites-nous savoir ce dont vous avez besoin, nous nous occupons du reste.', 'de': 'Lassen Sie uns wissen, was Sie brauchen, wir erledigen den Rest.',
      'ru': 'Сообщите нам, что вам нужно, и мы позаботимся об остальном.', 'zh': '告诉我们您的需求，剩下的交给我们。', 'ja': '必要なものをお知らせください。あとはお任せください。'
    },
    'Select a category to get started': {
      'ar': 'حدد فئة للبدء', 'es': 'Seleccione una categoría para empezar', 'fr': 'Sélectionnez une catégorie pour commencer', 'de': 'Wählen Sie eine Kategorie, um zu beginnen',
      'ru': 'Выберите категорию для начала', 'zh': '选择一个类别开始', 'ja': '開始するカテゴリを選択してください'
    },
    'Custom Request': {
      'ar': 'طلب مخصص', 'es': 'Solicitud Personalizada', 'fr': 'Demande Personnalisée', 'de': 'Benutzerdefinierte Anfrage',
      'ru': 'Индивидуальный Запрос', 'zh': '自定义请求', 'ja': 'カスタムリクエスト'
    },
    'Didn\'t find what you need? Describe it here.': {
      'ar': 'لم تجد ما تحتاجه؟ صفه هنا.', 'es': '¿No encontró lo que necesita? Descríbalo aquí.', 'fr': 'Vous n\'avez pas trouvé ce qu\'il vous faut ? Décrivez-le ici.', 'de': 'Nicht gefunden, was Sie brauchen? Beschreiben Sie es hier.',
      'ru': 'Не нашли то, что искали? Опишите это здесь.', 'zh': '没找到您需要的？在这里描述。', 'ja': '必要なものが見つかりませんか？こちらに詳細をご記入ください。'
    },
    'Please provide the details of your request below.': {
      'ar': 'يرجى تقديم تفاصيل طلبك أدناه.', 'es': 'Proporcione los detalles de su solicitud a continuación.', 'fr': 'Veuillez fournir les détails de votre demande ci-dessous.', 'de': 'Bitte geben Sie unten die Details Ihrer Anfrage an.',
      'ru': 'Пожалуйста, укажите детали вашего запроса ниже.', 'zh': '请在下面提供您的请求详情。', 'ja': '以下にリクエストの詳細を提供してください。'
    },
    'Type your request here...': {
      'ar': 'اكتب طلبك هنا...', 'es': 'Escriba su solicitud aquí...', 'fr': 'Tapez votre demande ici...', 'de': 'Geben Sie hier Ihre Anfrage ein...',
      'ru': 'Введите ваш запрос здесь...', 'zh': '在此处输入您的请求...', 'ja': 'ここにリクエストを入力してください...'
    },
    'Attachments (Optional)': {
      'ar': 'المرفقات (اختياري)', 'es': 'Adjuntos (Opcional)', 'fr': 'Pièces jointes (Optionnel)', 'de': 'Anhänge (Optional)',
      'ru': 'Вложения (Необязательно)', 'zh': '附件 (可选)', 'ja': '添付ファイル (オプション)'
    },
    'Add Image': {
      'ar': 'إضافة صورة', 'es': 'Añadir Imagen', 'fr': 'Ajouter une Image', 'de': 'Bild Hinzufügen',
      'ru': 'Добавить Изображение', 'zh': '添加图片', 'ja': '画像を追加'
    },
    'Voice Note': {
      'ar': 'ملاحظة صوتية', 'es': 'Nota de Voz', 'fr': 'Note Vocale', 'de': 'Sprachnotiz',
      'ru': 'Голосовая Заметка', 'zh': '语音备注', 'ja': 'ボイスメモ'
    },
    'SUBMIT REQUEST': {
      'ar': 'إرسال الطلب', 'es': 'ENVIAR SOLICITUD', 'fr': 'SOUMETTRE LA DEMANDE', 'de': 'ANFRAGE ABSENDEN',
      'ru': 'ОТПРАВИТЬ ЗАПРОС', 'zh': '提交请求', 'ja': 'リクエストを送信'
    },
    'Submit Request': {
      'ar': 'إرسال الطلب', 'es': 'Enviar Solicitud', 'fr': 'Soumettre la Demande', 'de': 'Anfrage Absenden',
      'ru': 'Отправить Запрос', 'zh': '提交请求', 'ja': 'リクエストを送信'
    },
    'Available Services': {
      'ar': 'الخدمات المتاحة', 'es': 'Servicios Disponibles', 'fr': 'Services Disponibles', 'de': 'Verfügbare Dienste',
      'ru': 'Доступные Услуги', 'zh': '可用服务', 'ja': '利用可能なサービス'
    },
    'Appetizers': {
      'ar': 'المقبلات', 'es': 'Aperitivos', 'fr': 'Apéritifs', 'de': 'Vorspeisen',
      'ru': 'Закуски', 'zh': '开胃菜', 'ja': '前菜'
    },
    'Main Course': {
      'ar': 'الطبق الرئيسي', 'es': 'Plato Principal', 'fr': 'Plat Principal', 'de': 'Hauptgericht',
      'ru': 'Главное Блюдо', 'zh': '主菜', 'ja': 'メインコース'
    },
    'Desserts': {
      'ar': 'الحلويات', 'es': 'Postres', 'fr': 'Desserts', 'de': 'Desserts',
      'ru': 'Десерты', 'zh': '甜点', 'ja': 'デザート'
    },
    'Beverages': {
      'ar': 'المشروبات', 'es': 'Bebidas', 'fr': 'Boissons', 'de': 'Getränke',
      'ru': 'Напитки', 'zh': '饮料', 'ja': '飲み物'
    },
    'Soups': {
      'ar': 'الشوربات', 'es': 'Sopas', 'fr': 'Soupes', 'de': 'Suppen',
      'ru': 'Супы', 'zh': '汤类', 'ja': 'スープ'
    },
    'Salads': {
      'ar': 'السلطات', 'es': 'Ensaladas', 'fr': 'Salades', 'de': 'Salate',
      'ru': 'Салаты', 'zh': '沙拉', 'ja': 'サラダ'
    },
    'General': {
      'ar': 'عام', 'es': 'General', 'fr': 'Général', 'de': 'Allgemein',
      'ru': 'Общее', 'zh': '一般', 'ja': '一般'
    },
    'Breakfast': {
      'ar': 'الإفطار', 'es': 'Desayuno', 'fr': 'Petit-déjeuner', 'de': 'Frühstück',
      'ru': 'Завтрак', 'zh': '早餐', 'ja': '朝食'
    },
    'Lunch': {
      'ar': 'الغداء', 'es': 'Almuerzo', 'fr': 'Déjeuner', 'de': 'Mittagessen',
      'ru': 'Обед', 'zh': '午餐', 'ja': '昼食'
    },
    'Dinner': {
      'ar': 'العشاء', 'es': 'Cena', 'fr': 'Dîner', 'de': 'Abendessen',
      'ru': 'Ужин', 'zh': '晚餐', 'ja': '夕食'
    },
    'Drinks': {
      'ar': 'مشروبات', 'es': 'Bebidas', 'fr': 'Boissons', 'de': 'Getränke',
      'ru': 'Напитки', 'zh': '饮品', 'ja': 'ドリンク'
    },
    'Hot Drinks': {
      'ar': 'مشروبات ساخنة', 'es': 'Bebidas Calientes', 'fr': 'Boissons Chaudes', 'de': 'Heiße Getränke',
      'ru': 'Горячие Напитки', 'zh': '热饮', 'ja': 'ホットドリンク'
    },
    'Cold Drinks': {
      'ar': 'مشروبات باردة', 'es': 'Bebidas Frías', 'fr': 'Boissons Froides', 'de': 'Kalte Getränke',
      'ru': 'Холодные Напитки', 'zh': '冷饮', 'ja': 'コールドドリンク'
    },
    'Starters': {
      'ar': 'بدايات', 'es': 'Entrantes', 'fr': 'Entrées', 'de': 'Vorspeisen',
      'ru': 'Стартеры', 'zh': '前菜', 'ja': 'スターター'
    },
    'Select a service below to create your request.': {
      'ar': 'حدد خدمة أدناه لإنشاء طلبك.', 'es': 'Seleccione un servicio a continuación para crear su solicitud.', 'fr': 'Sélectionnez un service ci-dessous pour créer votre demande.', 'de': 'Wählen Sie unten einen Dienst aus, um Ihre Anfrage zu erstellen.',
      'ru': 'Выберите услугу ниже, чтобы создать ваш запрос.', 'zh': '在下面选择一项服务以创建您的请求。', 'ja': '以下のサービスを選択してリクエストを作成してください。'
    },
    'Need something else?': {
      'ar': 'هل تحتاج إلى شيء آخر؟', 'es': '¿Necesita algo más?', 'fr': 'Besoin d\'autre chose ?', 'de': 'Brauchen Sie noch etwas?',
      'ru': 'Нужно что-то еще?', 'zh': '还需要别的吗？', 'ja': '他に何か必要ですか？'
    },
    'Write a custom request for this category.': {
      'ar': 'اكتب طلبًا مخصصًا لهذه الفئة.', 'es': 'Escriba una solicitud personalizada para esta categoría.', 'fr': 'Rédigez une demande personnalisée pour cette catégorie.', 'de': 'Schreiben Sie eine benutzerdefinierte Anfrage für diese Kategorie.',
      'ru': 'Напишите индивидуальный запрос для этой категории.', 'zh': '为此类别编写自定义请求。', 'ja': 'このカテゴリのカスタムリクエストを記述してください。'
    },
    'Good Morning,': {
      'ar': 'صباح الخير،', 'es': 'Buenos días,', 'fr': 'Bonjour,', 'de': 'Guten Morgen,',
      'ru': 'Доброе утро,', 'zh': '早上好，', 'ja': 'おはようございます、'
    },
    'Good Afternoon,': {
      'ar': 'طاب مساؤك،', 'es': 'Buenas tardes,', 'fr': 'Bon après-midi,', 'de': 'Guten Tag,',
      'ru': 'Добрый день,', 'zh': '下午好，', 'ja': 'こんにちは、'
    },
    'Good Evening,': {
      'ar': 'مساء الخير،', 'es': 'Buenas noches,', 'fr': 'Bonsoir,', 'de': 'Guten Abend,',
      'ru': 'Добрый вечер,', 'zh': '晚上好，', 'ja': 'こんばんは、'
    },
    'Room': {
      'ar': 'غرفة', 'es': 'Habitación', 'fr': 'Chambre', 'de': 'Zimmer',
      'ru': 'Номер', 'zh': '房间', 'ja': '部屋'
    },
    'Guest': {
      'ar': 'ضيف', 'es': 'Huésped', 'fr': 'Invité', 'de': 'Gast',
      'ru': 'Гость', 'zh': '客人', 'ja': 'ゲスト'
    },
    'WELCOME': {
      'ar': 'أهلاً بك', 'es': 'BIENVENIDO', 'fr': 'BIENVENUE', 'de': 'WILLKOMMEN',
      'ru': 'ДОБРО ПОЖАЛОВАТЬ', 'zh': '欢迎', 'ja': 'ようこそ'
    },
    'Check-in': {
      'ar': 'تسجيل الدخول', 'es': 'Check-in', 'fr': 'Arrivée', 'de': 'Check-in',
      'ru': 'Заезд', 'zh': '入住', 'ja': 'チェックイン'
    },
    'Check-out': {
      'ar': 'تسجيل الخروج', 'es': 'Check-out', 'fr': 'Départ', 'de': 'Check-out',
      'ru': 'Выезд', 'zh': '退房', 'ja': 'チェックアウト'
    },
    'Create Request': {
      'ar': 'إنشاء طلب', 'es': 'Crear Solicitud', 'fr': 'Créer une Demande', 'de': 'Anfrage Erstellen',
      'ru': 'Создать Запрос', 'zh': '创建请求', 'ja': 'リクエストを作成'
    },
    'Guest Services Chat': {
      'ar': 'محادثة خدمات الضيوف', 'es': 'Chat de Servicios para Huéspedes', 'fr': 'Chat des Services aux Invités', 'de': 'Gäste-Service-Chat',
      'ru': 'Чат Обслуживания Гостей', 'zh': '客房服务聊天', 'ja': 'ゲストサービスチャット'
    },
    'How Can We Help?': {
      'ar': 'كيف يمكننا مساعدتك؟', 'es': '¿Cómo Podemos Ayudar?', 'fr': 'Comment Pouvons-Nous Aider ?', 'de': 'Wie Können Wir Helfen?',
      'ru': 'Чем Мы Можем Помочь?', 'zh': '我们能怎么帮助您？', 'ja': 'どのようにお手伝いしましょうか？'
    },
    'Dining Experiences': {
      'ar': 'تجارب تناول الطعام', 'es': 'Experiencias Gastronómicas', 'fr': 'Expériences Gastronomiques', 'de': 'Kulinarische Erlebnisse',
      'ru': 'Ресторанные Впечатления', 'zh': '餐饮体验', 'ja': 'ダイニング体験'
    },
    'View All': {
      'ar': 'عرض الكل', 'es': 'Ver Todo', 'fr': 'Voir Tout', 'de': 'Alle Ansehen',
      'ru': 'Посмотреть Все', 'zh': '查看全部', 'ja': 'すべて表示'
    },
    'View Details': {
      'ar': 'عرض التفاصيل', 'es': 'Ver Detalles', 'fr': 'Voir les Détails', 'de': 'Details Ansehen',
      'ru': 'Посмотреть Детали', 'zh': '查看详情', 'ja': '詳細を見る'
    },
    'No local recommendations available.': {
      'ar': 'لا توجد توصيات محلية متاحة.', 'es': 'No hay recomendaciones locales disponibles.', 'fr': 'Aucune recommandation locale disponible.', 'de': 'Keine lokalen Empfehlungen verfügbar.',
      'ru': 'Нет доступных местных рекомендаций.', 'zh': '没有可用的本地推荐。', 'ja': 'ローカルな推奨事項はありません。'
    },
    'CREATE NEW REQUEST': {
      'ar': 'إنشاء طلب جديد', 'es': 'CREAR NUEVA SOLICITUD', 'fr': 'CRÉER UNE NOUVELLE DEMANDE', 'de': 'NEUE ANFRAGE ERSTELLEN',
      'ru': 'СОЗДАТЬ НОВЫЙ ЗАПРОС', 'zh': '创建新请求', 'ja': '新しいリクエストを作成'
    },
    'Confirm Order': {
      'ar': 'تأكيد الطلب', 'es': 'Confirmar Pedido', 'fr': 'Confirmer la Commande', 'de': 'Bestellung Bestätigen',
      'ru': 'Подтвердить Заказ', 'zh': '确认订单', 'ja': '注文を確認'
    },
    'Add to Cart': {
      'ar': 'أضف إلى السلة', 'es': 'Añadir al Carrito', 'fr': 'Ajouter au Panier', 'de': 'In den Warenkorb',
      'ru': 'Добавить в Корзину', 'zh': '加入购物车', 'ja': 'カートに追加'
    },
    'Confirm Reservation': {
      'ar': 'تأكيد الحجز', 'es': 'Confirmar Reserva', 'fr': 'Confirmer la Réservation', 'de': 'Reservierung Bestätigen',
      'ru': 'Подтвердить Бронирование', 'zh': '确认预订', 'ja': '予約を確認'
    },
    'Place Laundry Order': {
      'ar': 'طلب غسيل', 'es': 'Hacer Pedido de Lavandería', 'fr': 'Passer Commande de Blanchisserie', 'de': 'Wäschebestellung Aufgeben',
      'ru': 'Разместить Заказ на Прачечную', 'zh': '下洗衣订单', 'ja': 'ランドリーの注文をする'
    },
    'Add to Bag': {
      'ar': 'أضف إلى الحقيبة', 'es': 'Añadir a la Bolsa', 'fr': 'Ajouter au Sac', 'de': 'Zur Tasche Hinzufügen',
      'ru': 'Добавить в Сумку', 'zh': '添加到袋子', 'ja': 'バッグに追加'
    },
    'Reserve Table': {
      'ar': 'حجز طاولة', 'es': 'Reservar Mesa', 'fr': 'Réserver une Table', 'de': 'Tisch Reservieren',
      'ru': 'Забронировать Стол', 'zh': '预订餐桌', 'ja': 'テーブルを予約'
    },
    'View Menu': {
      'ar': 'عرض القائمة', 'es': 'Ver Menú', 'fr': 'Voir le Menu', 'de': 'Menü Ansehen',
      'ru': 'Посмотреть Меню', 'zh': '查看菜单', 'ja': 'メニューを見る'
    },
    'REQUEST PICKUP': {
      'ar': 'طلب استلام', 'es': 'SOLICITAR RECOGIDA', 'fr': 'DEMANDER LE RAMASSAGE', 'de': 'ABHOLUNG ANFORDERN',
      'ru': 'ЗАПРОСИТЬ ЗАБОР', 'zh': '请求取件', 'ja': '集荷をリクエスト'
    },
    'No past laundry orders.': {
      'ar': 'لا توجد طلبات غسيل سابقة.', 'es': 'No hay pedidos de lavandería anteriores.', 'fr': 'Aucune commande de blanchisserie passée.', 'de': 'Keine früheren Wäschebestellungen.',
      'ru': 'Нет прошлых заказов на прачечную.', 'zh': '没有过去的洗衣订单。', 'ja': '過去のランドリーの注文はありません。'
    },

    // ── Laundry Categories & Services ──
    'Standard': {
      'ar': 'عادي', 'es': 'Estándar', 'fr': 'Standard', 'de': 'Standard',
      'ru': 'Стандарт', 'zh': '标准', 'ja': '標準'
    },
    'Pressing': {
      'ar': 'كي', 'es': 'Planchado', 'fr': 'Repassage', 'de': 'Bügeln',
      'ru': 'Глажка', 'zh': '熨烫', 'ja': 'プレス'
    },
    'Dry Cleaning': {
      'ar': 'تنظيف جاف', 'es': 'Lavado en Seco', 'fr': 'Nettoyage à Sec', 'de': 'Chemische Reinigung',
      'ru': 'Химчистка', 'zh': '干洗', 'ja': 'ドライクリーニング'
    },
    'Dry cleaning': {
      'ar': 'تنظيف جاف', 'es': 'Lavado en Seco', 'fr': 'Nettoyage à Sec', 'de': 'Chemische Reinigung',
      'ru': 'Химчистка', 'zh': '干洗', 'ja': 'ドライクリーニング'
    },
    'dry_cleaning': {
      'ar': 'تنظيف جاف', 'es': 'Lavado en Seco', 'fr': 'Nettoyage à Sec', 'de': 'Chemische Reinigung',
      'ru': 'Химчистка', 'zh': '干洗', 'ja': 'ドライクリーニング'
    },
    'Standard Laundry': {
      'ar': 'غسيل عادي', 'es': 'Lavandería Estándar', 'fr': 'Blanchisserie Standard', 'de': 'Standard-Wäsche',
      'ru': 'Стандартная стирка', 'zh': '标准洗衣', 'ja': '標準ランドリー'
    },
    'Pressing Only': {
      'ar': 'كي فقط', 'es': 'Solo Planchado', 'fr': 'Repassage Uniquement', 'de': 'Nur Bügeln',
      'ru': 'Только глажка', 'zh': '仅熨烫', 'ja': 'プレスのみ'
    },
    'Laundry & Pressing': {
      'ar': 'غسيل وكي', 'es': 'Lavandería y Planchado', 'fr': 'Blanchisserie et Repassage', 'de': 'Wäsche & Bügeln',
      'ru': 'Стирка и глажка', 'zh': '洗衣与熨烫', 'ja': '洗濯＆プレス'
    },
    'Impeccable Care for Your Wardrobe': {
      'ar': 'عناية فائقة بملابسك', 'es': 'Cuidado impecable para su guardarropa', 'fr': 'Un soin impeccable pour votre garde-robe', 'de': 'Tadellose Pflege für Ihre Garderobe',
      'ru': 'Безупречный уход за вашим гардеробом', 'zh': '为您的衣物提供无可挑剔的呵护', 'ja': 'ワードローブを完璧にお手入れ'
    },
    'Leave your laundry to us and step out in style.': {
      'ar': 'اترك غسيل ملابسك لنا وتألق بأناقة.', 'es': 'Deje su ropa con nosotros y luzca con estilo.', 'fr': 'Confiez-nous votre linge et sortez avec style.', 'de': 'Überlassen Sie uns Ihre Wäsche und treten Sie stilvoll auf.',
      'ru': 'Доверьте нам свою одежду и выглядите безупречно.', 'zh': '将衣物交给我们，自信展现魅力。', 'ja': 'お洗濯は私共にお任せいただき、スマートにお出かけください。'
    },
    'My Laundry Orders': {
      'ar': 'طلبات الغسيل الخاصة بي', 'es': 'Mis Pedidos de Lavandería', 'fr': 'Mes Commandes de Blanchisserie', 'de': 'Meine Wäschebestellungen',
      'ru': 'Мои заказы на прачечную', 'zh': '我的洗衣订单', 'ja': 'ランドリーの注文履歴'
    },
    'Your Laundry Bag': {
      'ar': 'حقيبة الغسيل الخاصة بك', 'es': 'Su Bolsa de Lavandería', 'fr': 'Votre Sac de Blanchisserie', 'de': 'Ihre Wäschetasche',
      'ru': 'Ваша сумка для стирки', 'zh': '您的洗衣袋', 'ja': 'ランドリーバッグ'
    },
    'No services in this category.': {
      'ar': 'لا توجد خدمات في هذه الفئة.', 'es': 'No hay servicios en esta categoría.', 'fr': 'Aucun service dans cette catégorie.', 'de': 'Keine Dienstleistungen in dieser Kategorie.',
      'ru': 'В этой категории нет услуг.', 'zh': '此类别中暂无服务。', 'ja': 'このカテゴリにはサービスがありません。'
    },
    'No laundry services available.': {
      'ar': 'لا تتوفر خدمات غسيل حالياً.', 'es': 'No hay servicios de lavandería disponibles.', 'fr': 'Aucun service de blanchisserie disponible.', 'de': 'Keine Wäscheservices verfügbar.',
      'ru': 'Услуги прачечной недоступны.', 'zh': '暂无可用洗衣服务。', 'ja': '現在ランドリーサービスはご利用いただけません。'
    },
    'View Bag': {
      'ar': 'عرض الحقيبة', 'es': 'Ver Bolsa', 'fr': 'Voir le Sac', 'de': 'Tasche Anzeigen',
      'ru': 'Посмотреть сумку', 'zh': '查看袋子', 'ja': 'バッグを見る'
    },

    'Explore Our Culinary Venues': {
      'ar': 'استكشف مطاعمنا', 'es': 'Explore Nuestros Locales Culinarios', 'fr': 'Découvrez nos Lieux Culinaires', 'de': 'Entdecken Sie unsere kulinarischen Orte',
      'ru': 'Откройте для себя наши кулинарные заведения', 'zh': '探索我们的美食场所', 'ja': '私たちの料理の場を探索する'
    },
    'Discover a world of flavors tailored for every moment of your stay.': {
      'ar': 'اكتشف عالمًا من النكهات المصممة لكل لحظة من إقامتك.', 'es': 'Descubra un mundo de sabores adaptados para cada momento de su estancia.', 'fr': 'Découvrez un monde de saveurs adaptées à chaque moment de votre séjour.', 'de': 'Entdecken Sie eine Welt voller Aromen, maßgeschneidert für jeden Moment Ihres Aufenthalts.',
      'ru': 'Откройте для себя мир вкусов, созданных для каждого момента вашего пребывания.', 'zh': '探索为您入住的每一刻量身定制的风味世界。', 'ja': '滞在のあらゆる瞬間に合わせた味の世界を発見してください。'
    },
    'No Venues Available': {
      'ar': 'لا توجد أماكن متاحة', 'es': 'No hay lugares disponibles', 'fr': 'Aucun lieu disponible', 'de': 'Keine Veranstaltungsorte verfügbar',
      'ru': 'Нет доступных заведений', 'zh': '没有可用的场所', 'ja': '利用可能な会場はありません'
    },
    'Please check back later or pull down to refresh.': {
      'ar': 'يرجى التحقق لاحقًا أو السحب لأسفل للتحديث.', 'es': 'Por favor, vuelva más tarde o deslice hacia abajo para actualizar.', 'fr': 'Veuillez vérifier plus tard ou tirer vers le bas pour rafraîchir.', 'de': 'Bitte schauen Sie später wieder vorbei oder ziehen Sie nach unten, um zu aktualisieren.',
      'ru': 'Пожалуйста, зайдите позже или потяните вниз, чтобы обновить.', 'zh': '请稍后再回来查看，或下拉刷新。', 'ja': '後でもう一度確認するか、下にスワイプして更新してください。'
    },
    'OPEN': {
      'ar': 'مفتوح', 'es': 'ABIERTO', 'fr': 'OUVERT', 'de': 'OFFEN',
      'ru': 'ОТКРЫТО', 'zh': '营业中', 'ja': '営業中'
    },
    'CLOSED': {
      'ar': 'مغلق', 'es': 'CERRADO', 'fr': 'FERMÉ', 'de': 'GESCHLOSSEN',
      'ru': 'ЗАКРЫТО', 'zh': '休息中', 'ja': '休業'
    },
    'VIEW MENU': {
      'ar': 'عرض القائمة', 'es': 'VER MENÚ', 'fr': 'VOIR LE MENU', 'de': 'MENÜ ANSEHEN',
      'ru': 'ПОСМОТРЕТЬ МЕНЮ', 'zh': '查看菜单', 'ja': 'メニューを見る'
    },
    'VENUE DETAILS': {
      'ar': 'تفاصيل المكان', 'es': 'DETALLES DEL LUGAR', 'fr': 'DÉTAILS DU LIEU', 'de': 'VERANSTALTUNGSDETAILS',
      'ru': 'ДЕТАЛИ ЗАВЕДЕНИЯ', 'zh': '场所详情', 'ja': '会場の詳細'
    },
    'Notifications': {
      'ar': 'الإشعارات', 'es': 'Notificaciones', 'fr': 'Notifications', 'de': 'Benachrichtigungen',
      'ru': 'Уведомления', 'zh': '通知', 'ja': '通知'
    },
    'Mark all read': {
      'ar': 'تحديد الكل كمقروء', 'es': 'Marcar todo como leído', 'fr': 'Tout marquer comme lu', 'de': 'Alle als gelesen markieren',
      'ru': 'Отметить все как прочитанные', 'zh': '全部标为已读', 'ja': 'すべて既読にする'
    },
    'No notifications yet': {
      'ar': 'لا توجد إشعارات بعد', 'es': 'Aún no hay notificaciones', 'fr': 'Pas encore de notifications', 'de': 'Noch keine Benachrichtigungen',
      'ru': 'Пока нет уведомлений', 'zh': '暂无通知', 'ja': '通知はまだありません'
    },
    'We will let you know when there are updates.': {
      'ar': 'سنعلمك عند وجود تحديثات.', 'es': 'Le informaremos cuando haya actualizaciones.', 'fr': 'Nous vous tiendrons au courant des mises à jour.', 'de': 'Wir geben Ihnen Bescheid, wenn es Updates gibt.',
      'ru': 'Мы сообщим вам, когда появятся обновления.', 'zh': '有更新时我们会通知您。', 'ja': '更新がありましたらお知らせします。'
    },
    'Guest Services': {
      'ar': 'خدمات الضيوف', 'es': 'Servicios al Huésped', 'fr': 'Services aux Invités', 'de': 'Gästeservice',
      'ru': 'Гостевые Службы', 'zh': '客房服务', 'ja': 'ゲストサービス'
    },
    'Online 24/7': {
      'ar': 'متاح على مدار 24 ساعة', 'es': 'En línea 24/7', 'fr': 'En ligne 24/7', 'de': '24/7 Online',
      'ru': 'Онлайн 24/7', 'zh': '全天在线', 'ja': '24時間オンライン'
    },
    'Type your message...': {
      'ar': 'اكتب رسالتك...', 'es': 'Escriba su mensaje...', 'fr': 'Tapez votre message...', 'de': 'Nachricht eingeben...',
      'ru': 'Введите ваше сообщение...', 'zh': '输入您的消息...', 'ja': 'メッセージを入力してください...'
    },
    'Hotel Staff': {
      'ar': 'طاقم الفندق', 'es': 'Personal del Hotel', 'fr': 'Personnel de l\'hôtel', 'de': 'Hotelpersonal',
      'ru': 'Персонал Отеля', 'zh': '酒店员工', 'ja': 'ホテルスタッフ'
    },
    'Your Requests': {
      'ar': 'طلباتك', 'es': 'Tus Solicitudes', 'fr': 'Vos Demandes', 'de': 'Ihre Anfragen',
      'ru': 'Ваши Запросы', 'zh': '您的请求', 'ja': 'リクエスト'
    },
    'Track your active requests or create a new one.': {
      'ar': 'تتبع طلباتك النشطة أو أنشئ طلبًا جديدًا.', 'es': 'Siga sus solicitudes activas o cree una nueva.', 'fr': 'Suivez vos demandes actives ou créez-en une nouvelle.', 'de': 'Verfolgen Sie Ihre aktiven Anfragen oder erstellen Sie eine neue.',
      'ru': 'Отслеживайте ваши активные запросы или создайте новый.', 'zh': '跟踪您的活动请求或创建新请求。', 'ja': 'アクティブなリクエストを追跡するか、新しく作成します。'
    },
    'Recent History': {
      'ar': 'السجل الحديث', 'es': 'Historial Reciente', 'fr': 'Historique Récent', 'de': 'Kürzlicher Verlauf',
      'ru': 'Недавняя История', 'zh': '最近历史', 'ja': '最近の履歴'
    },
    'No pending requests. All caught up! 🎉': {
      'ar': 'لا توجد طلبات معلقة. كل شيء جاهز! 🎉', 'es': 'Sin solicitudes pendientes. ¡Todo listo! 🎉', 'fr': 'Aucune demande en attente. Tout est à jour! 🎉', 'de': 'Keine ausstehenden Anfragen. Alles erledigt! 🎉',
      'ru': 'Нет ожидающих запросов. Все готово! 🎉', 'zh': '没有待处理的请求。全都搞定了！🎉', 'ja': '保留中のリクエストはありません。すべて完了しました！🎉'
    },
    'In Progress': {
      'ar': 'قيد التنفيذ', 'es': 'En Progreso', 'fr': 'En Cours', 'de': 'In Bearbeitung',
      'ru': 'В Процессе', 'zh': '进行中', 'ja': '進行中'
    },
    'Approved': {
      'ar': 'موافق عليه', 'es': 'Aprobado', 'fr': 'Approuvé', 'de': 'Genehmigt',
      'ru': 'Одобрено', 'zh': '已批准', 'ja': '承認済み'
    },
    'Resolved': {
      'ar': 'تم الحل', 'es': 'Resuelto', 'fr': 'Résolu', 'de': 'Gelöst',
      'ru': 'Решено', 'zh': '解決済み', 'ja': '解決済み'
    },
    'Request': {
      'ar': 'طلب', 'es': 'Solicitud', 'fr': 'Demande', 'de': 'Anfrage',
      'ru': 'Запрос', 'zh': '请求', 'ja': 'リクエスト'
    },
    'Write a message to staff...': {
      'ar': 'اكتب رسالة للطاقم...', 'es': 'Escriba un mensaje al personal...', 'fr': 'Écrivez un message au personnel...', 'de': 'Schreiben Sie eine Nachricht an das Personal...',
      'ru': 'Напишите сообщение персоналу...', 'zh': '写消息给员工...', 'ja': 'スタッフにメッセージを書く...'
    },
    'You': {
      'ar': 'أنت', 'es': 'Tú', 'fr': 'Vous', 'de': 'Sie',
      'ru': 'Вы', 'zh': '您', 'ja': 'あなた'
    },
    'Staff': {
      'ar': 'طاقم العمل', 'es': 'Personal', 'fr': 'Personnel', 'de': 'Personal',
      'ru': 'Персонал', 'zh': '员工', 'ja': 'スタッフ'
    },
    'Luggage Down': {
      'ar': 'إنزال الأمتعة', 'es': 'Bajar Equipaje', 'fr': 'Descendre Bagages', 'de': 'Gepäck Runter',
      'ru': 'Спустить Багаж', 'zh': '搬下行李', 'ja': '荷物を下ろす'
    },
    'Luggage\nDown': {
      'ar': 'إنزال الأمتعة', 'es': 'Bajar Equipaje', 'fr': 'Descendre Bagages', 'de': 'Gepäck Runter',
      'ru': 'Спустить Багаж', 'zh': '搬下行李', 'ja': '荷物を下ろす'
    },
    'AC Usage Support': {
      'ar': 'دعم المكيف', 'es': 'Soporte de AC', 'fr': 'Support Clim', 'de': 'Klima-Support',
      'ru': 'Поддержка Кондиционера', 'zh': '空调支持', 'ja': 'エアコンサポート'
    },
    'AC Usage\nSupport': {
      'ar': 'دعم المكيف', 'es': 'Soporte de AC', 'fr': 'Support Clim', 'de': 'Klima-Support',
      'ru': 'Поддержка Кондиционера', 'zh': '空调支持', 'ja': 'エアコンサポート'
    },
    'Coffee Tray': {
      'ar': 'صينية قهوة', 'es': 'Bandeja de Café', 'fr': 'Plateau à Café', 'de': 'Kaffeetablett',
      'ru': 'Поднос с кофе', 'zh': '咖啡托盘', 'ja': 'コーヒートレイ'
    },
    'A/C On': {
      'ar': 'تشغيل المكيف', 'es': 'Encender AC', 'fr': 'Allumer Clim', 'de': 'Klima Ein',
      'ru': 'Включить Кондиционер', 'zh': '开空调', 'ja': 'エアコンオン'
    },
    'Extra Towels': {
      'ar': 'مناشف إضافية', 'es': 'Toallas Extra', 'fr': 'Serviettes Supplémentaires', 'de': 'Zusätzliche Handtücher',
      'ru': 'Дополнительные полотенца', 'zh': '额外毛巾', 'ja': '追加のタオル'
    },
    'Make Up Room': {
      'ar': 'تنظيف الغرفة', 'es': 'Limpiar Habitación', 'fr': 'Faire la Chambre', 'de': 'Zimmer Reinigen',
      'ru': 'Уборка Номера', 'zh': '打扫房间', 'ja': '部屋の清掃'
    },
    'Make Up\nRoom': {
      'ar': 'تنظيف الغرفة', 'es': 'Limpiar Habitación', 'fr': 'Faire la Chambre', 'de': 'Zimmer Reinigen',
      'ru': 'Уборка Номера', 'zh': '打扫房间', 'ja': '部屋の清掃'
    },
    'Collect Plates': {
      'ar': 'جمع الأطباق', 'es': 'Recoger Platos', 'fr': 'Ramasser les Assiettes', 'de': 'Teller Sammeln',
      'ru': 'Забрать Тарелки', 'zh': '收盘子', 'ja': 'お皿を下げる'
    },
    'WiFi Help': {
      'ar': 'مساعدة واي فاي', 'es': 'Ayuda con WiFi', 'fr': 'Aide WiFi', 'de': 'WLAN-Hilfe',
      'ru': 'Помощь с WiFi', 'zh': 'WiFi 帮助', 'ja': 'WiFi ヘルプ'
    },
    'Housekeeping': {
      'ar': 'خدمة الغرف', 'es': 'Limpieza', 'fr': 'Ménage', 'de': 'Zimmerreinigung',
      'ru': 'Уборка', 'zh': '客房服务', 'ja': 'ハウスキーピング'
    },
    'Room Service': {
      'ar': 'خدمة الطعام', 'es': 'Servicio a la Habitación', 'fr': 'Service d\'étage', 'de': 'Zimmerservice',
      'ru': 'Обслуживание номеров', 'zh': '送餐服务', 'ja': 'ルームサービス'
    },
    'I.T': {
      'ar': 'تقنية المعلومات', 'es': 'Informática', 'fr': 'Informatique', 'de': 'IT',
      'ru': 'IT', 'zh': 'IT', 'ja': 'IT'
    },
    'Maintenance': {
      'ar': 'الصيانة', 'es': 'Mantenimiento', 'fr': 'Maintenance', 'de': 'Wartung',
      'ru': 'Техническое обслуживание', 'zh': '维修', 'ja': 'メンテナンス'
    },
    'Reception': {
      'ar': 'الاستقبال', 'es': 'Recepción', 'fr': 'Réception', 'de': 'Rezeption',
      'ru': 'Ресепшн', 'zh': '前台', 'ja': '受付'
    },
    'Concierge': {
      'ar': 'الكونسيرج', 'es': 'Conserje', 'fr': 'Conciergerie', 'de': 'Concierge',
      'ru': 'Консьерж', 'zh': '礼宾部', 'ja': 'コンシェルジュ'
    },
    'Engineering': {
      'ar': 'الهندسة', 'es': 'Ingeniería', 'fr': 'Ingénierie', 'de': 'Technik',
      'ru': 'Инженерия', 'zh': '工程', 'ja': 'エンジニアリング'
    },
    'Transportation': {
      'ar': 'المواصلات', 'es': 'Transporte', 'fr': 'Transport', 'de': 'Transport',
      'ru': 'Транспорт', 'zh': '交通', 'ja': '交通機関'
    },
    'Bell Desk': {
      'ar': 'مكتب الحقائب', 'es': 'Botones', 'fr': 'Bagagiste', 'de': 'Gepäckservice',
      'ru': 'Посыльный', 'zh': '行李部', 'ja': 'ベルデスク'
    },
    'Valet': {
      'ar': 'خدمة السيارات', 'es': 'Aparcacoches', 'fr': 'Voiturier', 'de': 'Parkservice',
      'ru': 'Парковщик', 'zh': '代客泊车', 'ja': 'バレー'
    },
    'Spa': {
      'ar': 'المنتجع الصحي', 'es': 'Spa', 'fr': 'Spa', 'de': 'Spa',
      'ru': 'Спа', 'zh': '水疗', 'ja': 'スパ'
    },
    'Fitness': {
      'ar': 'اللياقة البدنية', 'es': 'Gimnasio', 'fr': 'Fitness', 'de': 'Fitness',
      'ru': 'Фитнес', 'zh': '健身', 'ja': 'フィットネス'
    },
    'Guest Relations': {
      'ar': 'علاقات النزلاء', 'es': 'Relaciones Públicas', 'fr': 'Relations Clients', 'de': 'Gästebetreuung',
      'ru': 'Связь с гостями', 'zh': '客房关系', 'ja': 'ゲストリレーションズ'
    },
    'IT': {
      'ar': 'تقنية المعلومات', 'es': 'Informática', 'fr': 'Informatique', 'de': 'IT',
      'ru': 'IT', 'zh': 'IT', 'ja': 'IT'
    },
    'Air Conditioning': {
      'ar': 'تكييف الهواء', 'es': 'Aire Acondicionado', 'fr': 'Climatisation', 'de': 'Klimaanlage',
      'ru': 'Кондиционер', 'zh': '空调', 'ja': 'エアコン'
    },
    'Carpentry': {
      'ar': 'النجارة', 'es': 'Carpintería', 'fr': 'Menuiserie', 'de': 'Zimmerei',
      'ru': 'Плотницкие работы', 'zh': '木工', 'ja': '大工仕事'
    },
    'Healthy & Safety': {
      'ar': 'الصحة والسلامة', 'es': 'Salud y Seguridad', 'fr': 'Santé et Sécurité', 'de': 'Gesundheit & Sicherheit',
      'ru': 'Здоровье и безопасность', 'zh': '健康与安全', 'ja': '健康と安全'
    },
    'Duty Manager': {
      'ar': 'مدير مناوب', 'es': 'Gerente de Turno', 'fr': 'Responsable de Garde', 'de': 'Diensthabender Manager',
      'ru': 'Дежурный менеджер', 'zh': '值班经理', 'ja': 'デューティーマネージャー'
    },
    'Guest Service Center': {
      'ar': 'مركز خدمة النزلاء', 'es': 'Centro de Servicio al Huésped', 'fr': 'Centre de Service Client', 'de': 'Gästeservice-Center',
      'ru': 'Центр обслуживания гостей', 'zh': '客房服务中心', 'ja': 'ゲストサービスセンター'
    },
    'Fire & Life safety': {
      'ar': 'السلامة من الحرائق', 'es': 'Seguridad contra Incendios', 'fr': 'Sécurité Incendie', 'de': 'Brandschutz',
      'ru': 'Пожарная безопасность', 'zh': '消防安全', 'ja': '火災予防と安全'
    },
    'Historical site': {
      'ar': 'موقع تاريخي', 'es': 'Sitio histórico', 'fr': 'Site historique', 'de': 'Historische Stätte',
      'ru': 'Историческое место', 'zh': '历史遗迹', 'ja': '史跡'
    },
    'Mall': {
      'ar': 'مركز تسوق', 'es': 'Centro comercial', 'fr': 'Centre commercial', 'de': 'Einkaufszentrum',
      'ru': 'Торговый центр', 'zh': '购物中心', 'ja': 'モール'
    },
    'Market': {
      'ar': 'سوق', 'es': 'Mercado', 'fr': 'Marché', 'de': 'Markt',
      'ru': 'Рынок', 'zh': '市场', 'ja': '市場'
    },
    'Shopping mall': {
      'ar': 'مركز تسوق', 'es': 'Centro comercial', 'fr': 'Centre commercial', 'de': 'Einkaufszentrum',
      'ru': 'Торговый центр', 'zh': '购物中心', 'ja': 'ショッピングモール'
    },
    'Bar & grill': {
      'ar': 'بار وشواية', 'es': 'Bar y Parrilla', 'fr': 'Bar & Grill', 'de': 'Bar & Grill',
      'ru': 'Бар и гриль', 'zh': '酒吧和烧烤', 'ja': 'バー＆グリル'
    },
    'Gaming lounge': {
      'ar': 'صالة ألعاب', 'es': 'Sala de juegos', 'fr': 'Salle de jeux', 'de': 'Gaming-Lounge',
      'ru': 'Игровой зал', 'zh': '游戏休息室', 'ja': 'ゲーミングラウンジ'
    },
    'Luxury lifestyle shopping mall': {
      'ar': 'مركز تسوق فاخر', 'es': 'Centro comercial de lujo', 'fr': 'Centre commercial de luxe', 'de': 'Luxus-Einkaufszentrum',
      'ru': 'Роскошный торговый центр', 'zh': '豪华生活购物中心', 'ja': '高級ライフスタイルショッピングモール'
    },

    'Train stations': {
      'ar': 'محطات القطار', 'es': 'Estaciones de tren', 'fr': 'Gares', 'de': 'Bahnhöfe',
      'ru': 'Железнодорожные станции', 'zh': '火车站', 'ja': '駅'
    },
    'Complete Your Order': {
      'ar': 'أكمل طلبك', 'es': 'Complete su pedido', 'fr': 'Complétez votre commande', 'de': 'Schließen Sie Ihre Bestellung ab',
      'ru': 'Завершите ваш заказ', 'zh': '完成您的订单', 'ja': 'ご注文を完了してください'
    },
    'Your Order': {
      'ar': 'طلبك', 'es': 'Su pedido', 'fr': 'Votre commande', 'de': 'Ihre Bestellung',
      'ru': 'Ваш заказ', 'zh': '您的订单', 'ja': 'ご注文'
    },
    'Cart is empty.': {
      'ar': 'العربة فارغة.', 'es': 'El carrito está vacío.', 'fr': 'Le panier est vide.', 'de': 'Der Einkaufswagen ist leer.',
      'ru': 'Корзина пуста.', 'zh': '购物车是空的。', 'ja': 'カートは空です。'
    },
    'Total:': {
      'ar': 'المجموع:', 'es': 'Total:', 'fr': 'Total :', 'de': 'Gesamt:',
      'ru': 'Итого:', 'zh': '总计：', 'ja': '合計：'
    },
    'Special Instructions': {
      'ar': 'تعليمات خاصة', 'es': 'Instrucciones especiales', 'fr': 'Instructions spéciales', 'de': 'Besondere Anweisungen',
      'ru': 'Особые инструкции', 'zh': '特别指示', 'ja': '特別なご要望'
    },
    'Any special instructions for your order...': {
      'ar': 'أي تعليمات خاصة لطلبك...', 'es': 'Cualquier instrucción especial para su pedido...', 'fr': 'Toute instruction spéciale pour votre commande...', 'de': 'Spezielle Anweisungen für Ihre Bestellung...',
      'ru': 'Любые особые инструкции для вашего заказа...', 'zh': '您的订单的任何特殊说明...', 'ja': 'ご注文に関する特別なご要望など...'
    },
    'Reservation Details': {
      'ar': 'تفاصيل الحجز', 'es': 'Detalles de la reserva', 'fr': 'Détails de la réservation', 'de': 'Reservierungsdetails',
      'ru': 'Детали бронирования', 'zh': '预订详情', 'ja': '予約の詳細'
    },
    'Date': {
      'ar': 'التاريخ', 'es': 'Fecha', 'fr': 'Date', 'de': 'Datum',
      'ru': 'Дата', 'zh': '日期', 'ja': '日付'
    },
    'Time': {
      'ar': 'الوقت', 'es': 'Hora', 'fr': 'Heure', 'de': 'Zeit',
      'ru': 'Время', 'zh': '时间', 'ja': '時間'
    },
    'Number of Guests': {
      'ar': 'عدد الضيوف', 'es': 'Número de invitados', 'fr': 'Nombre d\'invités', 'de': 'Anzahl der Gäste',
      'ru': 'Количество гостей', 'zh': '客人数量', 'ja': 'ゲスト数'
    },
    'Order confirmed! It will be delivered to your room.': {
      'ar': 'تم تأكيد الطلب! سيتم تسليمه إلى غرفتك.', 'es': '¡Pedido confirmado! Será entregado en su habitación.', 'fr': 'Commande confirmée ! Elle sera livrée dans votre chambre.', 'de': 'Bestellung bestätigt! Sie wird auf Ihr Zimmer geliefert.',
      'ru': 'Заказ подтвержден! Он будет доставлен в ваш номер.', 'zh': '订单已确认！它将被送到您的房间。', 'ja': 'ご注文が確定しました。お部屋にお届けします。'
    },
    'Order & Reservation confirmed!': {
      'ar': 'تم تأكيد الطلب والحجز!', 'es': '¡Pedido y reserva confirmados!', 'fr': 'Commande et réservation confirmées !', 'de': 'Bestellung & Reservierung bestätigt!',
      'ru': 'Заказ и бронирование подтверждены!', 'zh': '订单和预订已确认！', 'ja': 'ご注文とご予約が確定しました！'
    },
    'Reserve a Spot': {
      'ar': 'حجز مكان', 'es': 'Reservar un lugar', 'fr': 'Réserver une place', 'de': 'Einen Platz reservieren',
      'ru': 'Забронировать место', 'zh': '预订座位', 'ja': '席を予約する'
    },
    'Party Size': {
      'ar': 'عدد الأفراد', 'es': 'Tamaño del grupo', 'fr': 'Taille du groupe', 'de': 'Gruppengröße',
      'ru': 'Количество человек', 'zh': '聚会人数', 'ja': '人数'
    },
    'Preferred Time': {
      'ar': 'الوقت المفضل', 'es': 'Hora preferida', 'fr': 'Heure préférée', 'de': 'Bevorzugte Zeit',
      'ru': 'Предпочтительное время', 'zh': '首选时间', 'ja': '希望の時間'
    },
    'Contact Phone': {
      'ar': 'هاتف التواصل', 'es': 'Teléfono de contacto', 'fr': 'Téléphone de contact', 'de': 'Kontakttelefon',
      'ru': 'Контактный телефон', 'zh': '联系电话', 'ja': '連絡先電話番号'
    },
    'Your phone number': {
      'ar': 'رقم هاتفك', 'es': 'Tu número de teléfono', 'fr': 'Votre numéro de téléphone', 'de': 'Ihre Telefonnummer',
      'ru': 'Ваш номер телефона', 'zh': '你的电话号码', 'ja': 'あなたの電話番号'
    },
    'Special Requests': {
      'ar': 'طلبات خاصة', 'es': 'Peticiones especiales', 'fr': 'Demandes spéciales', 'de': 'Sonderwünsche',
      'ru': 'Особые пожелания', 'zh': '特殊要求', 'ja': '特別なリクエスト'
    },
    'Any special requests or dietary requirements...': {
      'ar': 'أي طلبات خاصة أو متطلبات غذائية...', 'es': 'Cualquier petición especial o requisito dietético...', 'fr': 'Toute demande spéciale ou exigence alimentaire...', 'de': 'Jegliche Sonderwünsche oder diätetische Anforderungen...',
      'ru': 'Любые особые пожелания или диетические требования...', 'zh': '任何特殊要求或饮食要求...', 'ja': '特別なリクエストや食事制限など...'
    },
    'Failed to make reservation. Please try again.': {
      'ar': 'فشل في إجراء الحجز. يرجى المحاولة مرة أخرى.', 'es': 'Error al hacer la reserva. Por favor intente nuevamente.', 'fr': 'Échec de la réservation. Veuillez réessayer.', 'de': 'Reservierung fehlgeschlagen. Bitte versuchen Sie es erneut.',
      'ru': 'Не удалось забронировать. Пожалуйста, попробуйте еще раз.', 'zh': '预订失败。请重试。', 'ja': '予約に失敗しました。もう一度お試しください。'
    },
    'Search places...': {
      'ar': 'البحث عن أماكن...', 'es': 'Buscar lugares...', 'fr': 'Rechercher des lieux...', 'de': 'Orte suchen...',
      'ru': 'Искать места...', 'zh': '搜索地点...', 'ja': '場所を検索...'
    },
    'No places found': {
      'ar': 'لم يتم العثور على أماكن', 'es': 'No se encontraron lugares', 'fr': 'Aucun lieu trouvé', 'de': 'Keine Orte gefunden',
      'ru': 'Места не найдены', 'zh': '没有找到地点', 'ja': '場所が見つかりません'
    },
    'Map': {
      'ar': 'الخريطة', 'es': 'Mapa', 'fr': 'Carte', 'de': 'Karte',
      'ru': 'Карта', 'zh': '地图', 'ja': '地図'
    },
    'Reserve': {
      'ar': 'حجز', 'es': 'Reservar', 'fr': 'Réserver', 'de': 'Reservieren',
      'ru': 'Забронировать', 'zh': '预订', 'ja': '予約'
    },
    'Ride': {
      'ar': 'توصيلة', 'es': 'Viaje', 'fr': 'Course', 'de': 'Fahrt',
      'ru': 'Поездка', 'zh': '乘车', 'ja': '乗車'
    },
    'Could not open map link': {
      'ar': 'تعذر فتح رابط الخريطة', 'es': 'No se pudo abrir el enlace del mapa', 'fr': "Impossible d'ouvrir le lien de la carte", 'de': 'Kartenlink konnte nicht geöffnet werden',
      'ru': 'Не удалось открыть ссылку на карту', 'zh': '无法打开地图链接', 'ja': 'マップのリンクを開けませんでした'
    },

    'View Cart': {
      'ar': 'عرض السلة', 'es': 'Ver carrito', 'fr': 'Voir le panier', 'de': 'Warenkorb ansehen',
      'ru': 'Посмотреть корзину', 'zh': '查看购物车', 'ja': 'カートを見る'
    },
    'added to cart!': {
      'ar': 'أضيف إلى السلة!', 'es': '¡añadido al carrito!', 'fr': 'ajouté au panier !', 'de': 'zum Warenkorb hinzugefügt!',
      'ru': 'добавлено в корзину!', 'zh': '已加入购物车！', 'ja': 'カートに追加されました！'
    },
    'Plumber': {
      'ar': 'السباكة', 'es': 'Plomería', 'fr': 'Plomberie', 'de': 'Klempnerei',
      'ru': 'Сантехника', 'zh': '水管维修', 'ja': '配管'
    },
    'Electrical': {
      'ar': 'الكهرباء', 'es': 'Eléctrico', 'fr': 'Électricité', 'de': 'Elektrik',
      'ru': 'Электрика', 'zh': '电气', 'ja': '電気'
    },
    'Pest Control': {
      'ar': 'مكافحة الحشرات', 'es': 'Control de plagas', 'fr': 'Lutte antiparasitaire', 'de': 'Schädlingsbekämpfung',
      'ru': 'Борьба с вредителями', 'zh': '害虫防治', 'ja': '害虫駆除'
    },
    'Security': {
      'ar': 'الأمن', 'es': 'Seguridad', 'fr': 'Sécurité', 'de': 'Sicherheit',
      'ru': 'Охрана', 'zh': '安全', 'ja': 'セキュリティ'
    },
    'Amenities': {
      'ar': 'مستلزمات الغرفة', 'es': 'Comodidades', 'fr': 'Commodités', 'de': 'Annehmlichkeiten',
      'ru': 'Удобства', 'zh': '便利设施', 'ja': 'アメニティ'
    },
    'Minibar': {
      'ar': 'الميني بار', 'es': 'Minibar', 'fr': 'Minibar', 'de': 'Minibar',
      'ru': 'Мини-бар', 'zh': '迷你吧', 'ja': 'ミニバー'
    },
    'Luggage': {
      'ar': 'الأمتعة', 'es': 'Equipaje', 'fr': 'Bagages', 'de': 'Gepäck',
      'ru': 'Багаж', 'zh': '行李', 'ja': '荷物'
    },
    'Wake-up Call': {
      'ar': 'مكالمة إيقاظ', 'es': 'Llamada de Despertador', 'fr': 'Réveil', 'de': 'Weckruf',
      'ru': 'Будильник', 'zh': '叫醒服务', 'ja': 'モーニングコール'
    },

    // ── Transportation options popup & detail screen ──
    'Available Transports': {
      'ar': 'وسائل النقل المتاحة', 'es': 'Transportes Disponibles', 'fr': 'Transports Disponibles', 'de': 'Verfügbare Transportmittel',
      'ru': 'Доступный транспорт', 'zh': '可用交通工具', 'ja': '利用可能な交通手段'
    },
    'To': {
      'ar': 'إلى', 'es': 'A', 'fr': 'Vers', 'de': 'Nach',
      'ru': 'В', 'zh': '前往', 'ja': '行き先'
    },
    'Custom Destination': {
      'ar': 'وجهة مخصصة', 'es': 'Destino Personalizado', 'fr': 'Destination Personnalisée', 'de': 'Individuelles Ziel',
      'ru': 'Свой пункт назначения', 'zh': '自定义目的地', 'ja': 'カスタム目的地'
    },
    'No transportation options available at the moment.': {
      'ar': 'لا تتوفر خيارات نقل حاليًا.', 'es': 'No hay opciones de transporte disponibles en este momento.', 'fr': 'Aucune option de transport disponible pour le moment.', 'de': 'Derzeit sind keine Transportoptionen verfügbar.',
      'ru': 'В данный момент нет доступных вариантов транспорта.', 'zh': '目前没有可用的交通选项。', 'ja': '現在ご利用可能な交通手段はありません。'
    },
    'Hotel Car': {
      'ar': 'سيارة الفندق', 'es': 'Coche del Hotel', 'fr': "Voiture de l'Hôtel", 'de': 'Hotelwagen',
      'ru': 'Автомобиль отеля', 'zh': '酒店用车', 'ja': 'ホテルの車'
    },
    'Premium car, up to {n} pax': {
      'ar': 'سيارة فاخرة، حتى {n} ركاب', 'es': 'Coche premium, hasta {n} pasajeros', 'fr': "Voiture premium, jusqu'à {n} passagers", 'de': 'Premium-Auto, bis zu {n} Personen',
      'ru': 'Автомобиль премиум-класса, до {n} пассажиров', 'zh': '高级轿车，最多 {n} 人', 'ja': 'プレミアムカー、最大{n}名'
    },
    'Spacious vehicle, up to {n} pax': {
      'ar': 'مركبة واسعة، حتى {n} ركاب', 'es': 'Vehículo espacioso, hasta {n} pasajeros', 'fr': "Véhicule spacieux, jusqu'à {n} passagers", 'de': 'Geräumiges Fahrzeug, bis zu {n} Personen',
      'ru': 'Просторный автомобиль, до {n} пассажиров', 'zh': '宽敞车辆，最多 {n} 人', 'ja': '広々とした車両、最大{n}名'
    },
    'up to {n} pax': {
      'ar': 'حتى {n} ركاب', 'es': 'hasta {n} pasajeros', 'fr': "jusqu'à {n} passagers", 'de': 'bis zu {n} Personen',
      'ru': 'до {n} пассажиров', 'zh': '最多 {n} 人', 'ja': '最大{n}名'
    },
    'Recommended': {
      'ar': 'موصى به', 'es': 'Recomendado', 'fr': 'Recommandé', 'de': 'Empfohlen',
      'ru': 'Рекомендуем', 'zh': '推荐', 'ja': 'おすすめ'
    },
    'Description': {
      'ar': 'الوصف', 'es': 'Descripción', 'fr': 'Description', 'de': 'Beschreibung',
      'ru': 'Описание', 'zh': '描述', 'ja': '説明'
    },
    'Destination': {
      'ar': 'الوجهة', 'es': 'Destino', 'fr': 'Destination', 'de': 'Ziel',
      'ru': 'Пункт назначения', 'zh': '目的地', 'ja': '目的地'
    },
    'Enter your destination': {
      'ar': 'أدخل وجهتك', 'es': 'Ingrese su destino', 'fr': 'Entrez votre destination', 'de': 'Geben Sie Ihr Ziel ein',
      'ru': 'Введите пункт назначения', 'zh': '输入您的目的地', 'ja': '目的地を入力してください'
    },
    'Fixed rate transfer': {
      'ar': 'توصيل بسعر ثابت', 'es': 'Traslado de tarifa fija', 'fr': 'Transfert à tarif fixe', 'de': 'Transfer zum Festpreis',
      'ru': 'Трансфер по фиксированной цене', 'zh': '固定费率接送', 'ja': '固定料金送迎'
    },
    'Passengers': {
      'ar': 'الركاب', 'es': 'Pasajeros', 'fr': 'Passagers', 'de': 'Passagiere',
      'ru': 'Пассажиры', 'zh': '乘客', 'ja': '乗客'
    },
    'Number of passengers': {
      'ar': 'عدد الركاب', 'es': 'Número de pasajeros', 'fr': 'Nombre de passagers', 'de': 'Anzahl der Passagiere',
      'ru': 'Количество пассажиров', 'zh': '乘客人数', 'ja': '乗客数'
    },
    'Max capacity: {n} passengers': {
      'ar': 'السعة القصوى: {n} ركاب', 'es': 'Capacidad máxima: {n} pasajeros', 'fr': 'Capacité maximale : {n} passagers', 'de': 'Maximale Kapazität: {n} Passagiere',
      'ru': 'Максимальная вместимость: {n} пассажиров', 'zh': '最大容量：{n} 名乘客', 'ja': '最大定員：{n}名'
    },
    'Pickup Time': {
      'ar': 'وقت الاستلام', 'es': 'Hora de Recogida', 'fr': 'Heure de Prise en Charge', 'de': 'Abholzeit',
      'ru': 'Время подачи', 'zh': '接送时间', 'ja': '送迎時間'
    },
    'Now': {
      'ar': 'الآن', 'es': 'Ahora', 'fr': 'Maintenant', 'de': 'Jetzt',
      'ru': 'Сейчас', 'zh': '现在', 'ja': '今すぐ'
    },
    'In 15 min': {
      'ar': 'خلال 15 دقيقة', 'es': 'En 15 min', 'fr': 'Dans 15 min', 'de': 'In 15 Min.',
      'ru': 'Через 15 мин', 'zh': '15 分钟后', 'ja': '15分後'
    },
    'In 30 min': {
      'ar': 'خلال 30 دقيقة', 'es': 'En 30 min', 'fr': 'Dans 30 min', 'de': 'In 30 Min.',
      'ru': 'Через 30 мин', 'zh': '30 分钟后', 'ja': '30分後'
    },
    'In 1 hour': {
      'ar': 'خلال ساعة', 'es': 'En 1 hora', 'fr': 'Dans 1 heure', 'de': 'In 1 Stunde',
      'ru': 'Через 1 час', 'zh': '1 小时后', 'ja': '1時間後'
    },
    'Schedule': {
      'ar': 'جدولة', 'es': 'Programar', 'fr': 'Planifier', 'de': 'Planen',
      'ru': 'Запланировать', 'zh': '预约', 'ja': '予約'
    },
    'Scheduled': {
      'ar': 'مجدول', 'es': 'Programado', 'fr': 'Planifié', 'de': 'Geplant',
      'ru': 'Запланировано', 'zh': '已预约', 'ja': '予約済み'
    },
    'Included': {
      'ar': 'ما يشمله', 'es': 'Incluido', 'fr': 'Inclus', 'de': 'Inbegriffen',
      'ru': 'Включено', 'zh': '包含', 'ja': '含まれるもの'
    },
    'Please enter a destination.': {
      'ar': 'يرجى إدخال الوجهة.', 'es': 'Por favor, ingrese un destino.', 'fr': 'Veuillez saisir une destination.', 'de': 'Bitte geben Sie ein Ziel ein.',
      'ru': 'Пожалуйста, введите пункт назначения.', 'zh': '请输入目的地。', 'ja': '目的地を入力してください。'
    },
    'Chauffeur Requested!': {
      'ar': 'تم طلب السائق!', 'es': '¡Chofer Solicitado!', 'fr': 'Chauffeur Demandé !', 'de': 'Chauffeur angefordert!',
      'ru': 'Водитель вызван!', 'zh': '已请求司机！', 'ja': '運転手をリクエストしました！'
    },
    'Your {name} is on the way. Please wait at the hotel lobby.': {
      'ar': '{name} الخاصة بك في الطريق. يرجى الانتظار في ردهة الفندق.', 'es': 'Su {name} está en camino. Por favor, espere en el vestíbulo del hotel.', 'fr': "Votre {name} est en route. Veuillez patienter dans le hall de l'hôtel.", 'de': 'Ihr {name} ist unterwegs. Bitte warten Sie in der Hotellobby.',
      'ru': 'Ваш {name} уже в пути. Пожалуйста, подождите в лобби отеля.', 'zh': '您的 {name} 正在途中。请在酒店大堂等候。', 'ja': 'お客様の{name}が向かっています。ホテルのロビーでお待ちください。'
    },
    'Request Sent ✓': {
      'ar': 'تم إرسال الطلب ✓', 'es': 'Solicitud Enviada ✓', 'fr': 'Demande Envoyée ✓', 'de': 'Anfrage gesendet ✓',
      'ru': 'Запрос отправлен ✓', 'zh': '请求已发送 ✓', 'ja': 'リクエスト送信済み ✓'
    },
    'Confirm & Request Chauffeur': {
      'ar': 'تأكيد وطلب سائق', 'es': 'Confirmar y Solicitar Chofer', 'fr': 'Confirmer et Demander un Chauffeur', 'de': 'Bestätigen & Chauffeur anfordern',
      'ru': 'Подтвердить и вызвать водителя', 'zh': '确认并请求司机', 'ja': '確認して運転手をリクエスト'
    },
    'Done': {
      'ar': 'تم', 'es': 'Hecho', 'fr': 'Terminé', 'de': 'Fertig',
      'ru': 'Готово', 'zh': '完成', 'ja': '完了'
    },
    'Error': {
      'ar': 'خطأ', 'es': 'Error', 'fr': 'Erreur', 'de': 'Fehler',
      'ru': 'Ошибка', 'zh': '错误', 'ja': 'エラー'
    },
    'Professional hotel driver': {
      'ar': 'سائق فندق محترف', 'es': 'Conductor profesional del hotel', 'fr': "Chauffeur professionnel de l'hôtel", 'de': 'Professioneller Hotelfahrer',
      'ru': 'Профессиональный водитель отеля', 'zh': '专业酒店司机', 'ja': 'プロのホテルドライバー'
    },
    'Professional hotel chauffeur': {
      'ar': 'سائق فندق خاص محترف', 'es': 'Chofer profesional del hotel', 'fr': "Chauffeur professionnel de l'hôtel", 'de': 'Professioneller Hotel-Chauffeur',
      'ru': 'Профессиональный шофёр отеля', 'zh': '专业酒店司机', 'ja': 'プロのホテル専属運転手'
    },
    'Spacious air-conditioned Toyota bus': {
      'ar': 'حافلة تويوتا واسعة ومكيفة', 'es': 'Autobús Toyota espacioso con aire acondicionado', 'fr': 'Bus Toyota spacieux et climatisé', 'de': 'Geräumiger klimatisierter Toyota-Bus',
      'ru': 'Просторный автобус Toyota с кондиционером', 'zh': '宽敞的带空调丰田巴士', 'ja': '広々としたエアコン付きトヨタバス'
    },
    'Spacious air-conditioned van': {
      'ar': 'فان واسع ومكيف', 'es': 'Furgoneta espaciosa con aire acondicionado', 'fr': 'Fourgonnette spacieuse et climatisée', 'de': 'Geräumiger klimatisierter Van',
      'ru': 'Просторный микроавтобус с кондиционером', 'zh': '宽敞的带空调厢式车', 'ja': '広々としたエアコン付きバン'
    },
    'Air-conditioned Toyota Corolla': {
      'ar': 'تويوتا كورولا مكيفة', 'es': 'Toyota Corolla con aire acondicionado', 'fr': 'Toyota Corolla climatisée', 'de': 'Klimatisierter Toyota Corolla',
      'ru': 'Toyota Corolla с кондиционером', 'zh': '带空调的丰田卡罗拉', 'ja': 'エアコン付きトヨタ カローラ'
    },
    'Air-conditioned luxury sedan': {
      'ar': 'سيارة سيدان فاخرة مكيفة', 'es': 'Sedán de lujo con aire acondicionado', 'fr': 'Berline de luxe climatisée', 'de': 'Klimatisierte Luxuslimousine',
      'ru': 'Седан класса люкс с кондиционером', 'zh': '带空调的豪华轿车', 'ja': 'エアコン付き高級セダン'
    },
    'Air-conditioned vehicle': {
      'ar': 'مركبة مكيفة', 'es': 'Vehículo con aire acondicionado', 'fr': 'Véhicule climatisé', 'de': 'Klimatisiertes Fahrzeug',
      'ru': 'Автомобиль с кондиционером', 'zh': '带空调车辆', 'ja': 'エアコン付き車両'
    },
    'Luggage storage available': {
      'ar': 'مساحة لتخزين الأمتعة متوفرة', 'es': 'Almacenamiento de equipaje disponible', 'fr': 'Espace bagages disponible', 'de': 'Gepäckaufbewahrung verfügbar',
      'ru': 'Есть место для багажа', 'zh': '提供行李存放空间', 'ja': '荷物スペースあり'
    },
    'Up to 14 passengers capacity': {
      'ar': 'سعة تصل إلى 14 راكبًا', 'es': 'Capacidad de hasta 14 pasajeros', 'fr': "Capacité jusqu'à 14 passagers", 'de': 'Platz für bis zu 14 Passagiere',
      'ru': 'Вместимость до 14 пассажиров', 'zh': '最多可容纳 14 名乘客', 'ja': '最大14名まで乗車可能'
    },
    'Ideal for large groups & families': {
      'ar': 'مثالي للمجموعات الكبيرة والعائلات', 'es': 'Ideal para grupos grandes y familias', 'fr': 'Idéal pour les grands groupes et les familles', 'de': 'Ideal für große Gruppen & Familien',
      'ru': 'Идеально для больших групп и семей', 'zh': '非常适合大型团体和家庭', 'ja': '大人数のグループやご家族に最適'
    },
    'Ideal for groups & families': {
      'ar': 'مثالي للمجموعات والعائلات', 'es': 'Ideal para grupos y familias', 'fr': 'Idéal pour les groupes et les familles', 'de': 'Ideal für Gruppen & Familien',
      'ru': 'Идеально для групп и семей', 'zh': '非常适合团体和家庭', 'ja': 'グループやご家族に最適'
    },
    'Real-time GPS tracking': {
      'ar': 'تتبع GPS في الوقت الفعلي', 'es': 'Seguimiento GPS en tiempo real', 'fr': 'Suivi GPS en temps réel', 'de': 'GPS-Echtzeitverfolgung',
      'ru': 'GPS-отслеживание в реальном времени', 'zh': '实时 GPS 追踪', 'ja': 'リアルタイムGPS追跡'
    },
    'Complimentary water bottles': {
      'ar': 'زجاجات مياه مجانية', 'es': 'Botellas de agua de cortesía', 'fr': "Bouteilles d'eau offertes", 'de': 'Kostenlose Wasserflaschen',
      'ru': 'Бесплатная вода в бутылках', 'zh': '免费瓶装水', 'ja': '無料のミネラルウォーター'
    },
    'Meet & greet at hotel lobby': {
      'ar': 'استقبال في ردهة الفندق', 'es': 'Recibimiento en el vestíbulo del hotel', 'fr': "Accueil dans le hall de l'hôtel", 'de': 'Empfang in der Hotellobby',
      'ru': 'Встреча в лобби отеля', 'zh': '酒店大堂迎接', 'ja': 'ホテルロビーでのお出迎え'
    },
    'Licensed local driver': {
      'ar': 'سائق محلي مرخص', 'es': 'Conductor local con licencia', 'fr': 'Chauffeur local agréé', 'de': 'Lizenzierter lokaler Fahrer',
      'ru': 'Лицензированный местный водитель', 'zh': '持证本地司机', 'ja': '認可を受けた地元ドライバー'
    },
    'Metered fare': {
      'ar': 'أجرة بالعداد', 'es': 'Tarifa por taxímetro', 'fr': 'Tarif au compteur', 'de': 'Taxameter-Tarif',
      'ru': 'Оплата по счётчику', 'zh': '按表计费', 'ja': 'メーター制運賃'
    },
    'Direct hotel booking': {
      'ar': 'حجز مباشر من الفندق', 'es': 'Reserva directa con el hotel', 'fr': "Réservation directe par l'hôtel", 'de': 'Direkte Hotelbuchung',
      'ru': 'Прямое бронирование через отель', 'zh': '酒店直接预订', 'ja': 'ホテル直接予約'
    },
    'Shared shuttle service': {
      'ar': 'خدمة نقل مشتركة', 'es': 'Servicio de lanzadera compartido', 'fr': 'Service de navette partagé', 'de': 'Gemeinsamer Shuttle-Service',
      'ru': 'Общий трансфер', 'zh': '共享接驳服务', 'ja': '乗り合いシャトルサービス'
    },
    'Budget-friendly option': {
      'ar': 'خيار اقتصادي', 'es': 'Opción económica', 'fr': 'Option économique', 'de': 'Preisgünstige Option',
      'ru': 'Бюджетный вариант', 'zh': '经济实惠之选', 'ja': 'お手頃な選択肢'
    },
    'Pickup from hotel entrance': {
      'ar': 'الاستلام من مدخل الفندق', 'es': 'Recogida en la entrada del hotel', 'fr': "Prise en charge à l'entrée de l'hôtel", 'de': 'Abholung am Hoteleingang',
      'ru': 'Посадка у входа в отель', 'zh': '酒店入口接客', 'ja': 'ホテルの入口でお迎え'
    }

  };

  static String tr(BuildContext context, String text, {bool listen = true}) {
    try {
      final provider = Provider.of<GuestPortalProvider>(context, listen: listen);
      final lang = provider.currentLanguage;
      if (lang == 'en') return text;

      if (_dict.containsKey(text) && _dict[text]!.containsKey(lang)) {
        return _dict[text]![lang]!;
      }

      // Case-insensitive fallback
      final lowerText = text.toLowerCase().trim();
      for (final key in _dict.keys) {
        if (key.toLowerCase() == lowerText) {
          if (_dict[key]!.containsKey(lang)) {
            return _dict[key]![lang]!;
          }
        }
      }
    } catch (_) {
      // Fallback if provider is not accessible in context
    }
    return text;
  }
}

// Extension to make it easier to use in widgets: 'Home'.tr(context)
extension StringTranslation on String {
  String tr(BuildContext context, {bool listen = true}) {
    return AppTranslations.tr(context, this, listen: listen);
  }

  /// Translates and substitutes `{placeholders}`, e.g. 'up to {n} pax'.trWith(context, {'n': '4'})
  String trWith(BuildContext context, Map<String, Object> params) {
    var result = AppTranslations.tr(context, this);
    params.forEach((k, v) => result = result.replaceAll('{$k}', v.toString()));
    return result;
  }
}