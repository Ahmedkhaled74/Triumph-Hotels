import 'package:flutter/material.dart';

class GuestServiceParser {
  static final Map<String, IconData> _emojiMap = {
    '🛏️': Icons.bed, '🛏': Icons.bed,
    '🍽️': Icons.restaurant_menu, '🍽': Icons.restaurant_menu,
    '🔧': Icons.build,
    '👥': Icons.people,
    '📞': Icons.phone,
    '📱': Icons.smartphone,
    '📧': Icons.email,
    '💬': Icons.chat,
    '🔔': Icons.notifications,
    '⏰': Icons.alarm,
    '🚗': Icons.directions_car,
    '🚕': Icons.local_taxi,
    '🚙': Icons.directions_car,
    '🚌': Icons.directions_bus,
    '🚐': Icons.airport_shuttle,
    '✈️': Icons.flight, '✈': Icons.flight,
    '🏊': Icons.pool,
    '🏋️': Icons.fitness_center, '🏋': Icons.fitness_center,
    '🧘': Icons.self_improvement,
    '💆': Icons.spa,
    '💅': Icons.pan_tool,
    '💇': Icons.content_cut,
    '🛁': Icons.bathtub,
    '🚿': Icons.shower,
    '🧴': Icons.sanitizer,
    '🧼': Icons.wash,
    '🧻': Icons.cleaning_services,
    '🧹': Icons.cleaning_services,
    '🧺': Icons.local_laundry_service,
    '👔': Icons.checkroom,
    '🧳': Icons.luggage,
    '🗝️': Icons.vpn_key, '🗝': Icons.vpn_key,
    '🔑': Icons.key,
    '🔐': Icons.lock,
    '🚪': Icons.door_front_door,
    '🛋️': Icons.chair, '🛋': Icons.chair,
    '🪑': Icons.chair,
    '💡': Icons.lightbulb,
    '🔦': Icons.flashlight_on,
    '🔌': Icons.power,
    '📺': Icons.tv,
    '💻': Icons.laptop,
    '🖥️': Icons.desktop_windows, '🖥': Icons.desktop_windows,
    '🖨️': Icons.print, '🖨': Icons.print,
    '📦': Icons.inventory_2,
    '📄': Icons.description,
    '💰': Icons.attach_money,
    '💳': Icons.credit_card,
    '💎': Icons.diamond,
    '🛠️': Icons.handyman, '🛠': Icons.handyman,
    '🔨': Icons.hardware,
    '⚙️': Icons.settings, '⚙': Icons.settings,
    '🎯': Icons.ads_click,
    '🎮': Icons.sports_esports,
    '🎭': Icons.theater_comedy,
    '🎬': Icons.movie,
    '🎤': Icons.mic,
    '🎧': Icons.headphones,
    '🎼': Icons.music_note,
    '🎹': Icons.piano,
    '🎸': Icons.music_note,
    '🎁': Icons.card_giftcard,
    '🎉': Icons.celebration,
    '☕': Icons.local_cafe,
    '🍵': Icons.emoji_food_beverage,
    '🧃': Icons.local_drink,
    '🥤': Icons.local_drink,
    '🍺': Icons.sports_bar,
    '🍷': Icons.wine_bar,
    '🍸': Icons.local_bar,
    '🍹': Icons.local_bar,
    '🥛': Icons.local_drink,
    '🍰': Icons.cake,
    '🧁': Icons.cake,
    '🍫': Icons.food_bank,
    '🍕': Icons.local_pizza,
    '🍔': Icons.lunch_dining,
    '🍟': Icons.fastfood,
    '🌭': Icons.fastfood,
    '🥪': Icons.fastfood,
    '🌮': Icons.fastfood,
    '🌯': Icons.fastfood,
    '🍣': Icons.set_meal,
    '🍜': Icons.ramen_dining,
    '🍝': Icons.dinner_dining,
    '🥗': Icons.restaurant,
    '🍇': Icons.restaurant,
    '🍉': Icons.restaurant,
    '🍊': Icons.restaurant,
    '🍋': Icons.restaurant,
    '🍌': Icons.restaurant,
    '🍍': Icons.restaurant,
    '🍎': Icons.restaurant,
    '🍓': Icons.restaurant,
    '🥝': Icons.restaurant,
    '🥑': Icons.restaurant,
    '🌍': Icons.public,
    '🗺️': Icons.map, '🗺': Icons.map,
    '🧭': Icons.explore,
    '🏔️': Icons.terrain, '🏔': Icons.terrain,
    '🏖️': Icons.beach_access, '🏖': Icons.beach_access,
    '🏝️': Icons.holiday_village, '🏝': Icons.holiday_village,
    '🏛️': Icons.account_balance, '🏛': Icons.account_balance,
    '🏗️': Icons.construction, '🏗': Icons.construction,
    '🏘️': Icons.holiday_village, '🏘': Icons.holiday_village,
    '🏠': Icons.home,
    '🏢': Icons.business,
    '🏥': Icons.local_hospital,
    '🏦': Icons.account_balance,
    '🏨': Icons.hotel,
    '🏪': Icons.store,
    '🏫': Icons.school,
    '🏬': Icons.storefront,
    '🏰': Icons.castle,
    '💒': Icons.favorite,
    '⛪': Icons.church,
    '🕌': Icons.mosque,
    '⛲': Icons.water,
    '⛺': Icons.park,
    '🌁': Icons.foggy,
    '🌃': Icons.nights_stay,
    '🏙️': Icons.location_city, '🏙': Icons.location_city,
    '🌄': Icons.wb_sunny,
    '🌅': Icons.wb_twilight,
    '🌉': Icons.landscape,
    '♨️': Icons.hot_tub, '♨': Icons.hot_tub,
    '🎠': Icons.attractions,
    '🎡': Icons.attractions,
    '🎢': Icons.attractions,
    '💈': Icons.spa,
    '🎪': Icons.festival,
    '🚂': Icons.train,
    '🚇': Icons.subway,
    '🚑': Icons.medical_services,
    '🚒': Icons.fire_truck,
    '🚓': Icons.local_police,
    '🚲': Icons.pedal_bike,
    '🛴': Icons.electric_scooter,
    '🛵': Icons.moped,
    '🏍️': Icons.two_wheeler, '🏍': Icons.two_wheeler,
    '⛽': Icons.local_gas_station,
    '🚨': Icons.emergency,
    '🚥': Icons.traffic,
    '⚓': Icons.anchor,
    '⛵': Icons.sailing,
    '🚤': Icons.directions_boat,
    '🛳️': Icons.directions_boat, '🛳': Icons.directions_boat,
    '🛎️': Icons.room_service, '🛎': Icons.room_service,
    '⌛': Icons.hourglass_empty,
    '⏱️': Icons.timer, '⏱': Icons.timer,
    '⏲️': Icons.timer, '⏲': Icons.timer,
    '🌡️': Icons.thermostat, '🌡': Icons.thermostat,
    '☀️': Icons.wb_sunny, '☀': Icons.wb_sunny,
    '⭐': Icons.star,
    '🌟': Icons.star_border,
    '☁️': Icons.cloud, '☁': Icons.cloud,
    '🌈': Icons.looks,
    '☂️': Icons.umbrella, '☂': Icons.umbrella,
    '⚡': Icons.flash_on,
    '❄️': Icons.ac_unit, '❄': Icons.ac_unit,
    '☃️': Icons.ac_unit, '☃': Icons.ac_unit,
    '🔥': Icons.local_fire_department,
    '💧': Icons.water_drop,
    '🌊': Icons.water,
    '📍': Icons.location_on,
    '🎓': Icons.school,
    '💼': Icons.work,
    '📊': Icons.bar_chart,
    '📈': Icons.trending_up,
    '📉': Icons.trending_down,
    '🔍': Icons.search,
    '🔎': Icons.search,
    '🔒': Icons.lock,
    '🔓': Icons.lock_open,
    '🔕': Icons.notifications_off,
    '📢': Icons.campaign,
    '📣': Icons.campaign,
    '💭': Icons.chat_bubble_outline,
    '🗨️': Icons.chat_bubble, '🗨': Icons.chat_bubble,
    '💤': Icons.snooze,
    '💪': Icons.fitness_center,
    '👍': Icons.thumb_up,
    '👎': Icons.thumb_down,
    '👏': Icons.sign_language,
    '🙏': Icons.volunteer_activism,
    '✅': Icons.check_circle,
    '❌': Icons.cancel,
    '⭕': Icons.radio_button_unchecked,
    '❓': Icons.help,
    '❗': Icons.warning,
    '⚠️': Icons.warning_amber, '⚠': Icons.warning_amber,
    '🚫': Icons.block,
    '✨': Icons.auto_awesome,
    '🎈': Icons.celebration,
    '🎀': Icons.card_giftcard,
    '🎊': Icons.celebration,
    '❤️': Icons.favorite, '❤': Icons.favorite,
    '💚': Icons.favorite,
    '💙': Icons.favorite,
    '💜': Icons.favorite,
    '🧡': Icons.favorite,
    '🩴': Icons.beach_access,
    '🥿': Icons.shopping_bag,
    '👞': Icons.shopping_bag,
    '🧦': Icons.shopping_bag,
    '🧤': Icons.pan_tool,
    '🧣': Icons.checkroom,
    '👗': Icons.checkroom,
    '👘': Icons.checkroom,
    '🛌': Icons.bed,
    '🪞': Icons.lens,
    '🪟': Icons.window,
    '🧽': Icons.cleaning_services,
    '🪒': Icons.face,
    '🧖': Icons.spa,
    '🪥': Icons.clean_hands,
    '🪣': Icons.cleaning_services,
    '🪠': Icons.plumbing,
    '🧰': Icons.home_repair_service,
    '🧯': Icons.fire_extinguisher,
    '☎️': Icons.phone, '☎': Icons.phone,
    '📟': Icons.pages,
    '📠': Icons.fax,
    '⌨️': Icons.keyboard, '⌨': Icons.keyboard,
    '鼠标': Icons.mouse, '🖱️': Icons.mouse, '🖱': Icons.mouse,
    '📷': Icons.camera_alt,
    '📹': Icons.videocam,
    '📻': Icons.radio,
    '🎚️': Icons.tune, '🎚': Icons.tune,
    '🎛️': Icons.tune, '🎛': Icons.tune,
    '🕰️': Icons.access_time_filled, '🕰': Icons.access_time_filled,
    '🕯️': Icons.wb_incandescent, '🕯': Icons.wb_incandescent,
    '🪔': Icons.light,
    '🪫': Icons.battery_0_bar,
    '💾': Icons.save,
    '💿': Icons.album,
    '📀': Icons.album,
    '🎥': Icons.movie_creation,
    '🎞️': Icons.local_movies, '🎞': Icons.local_movies,
    '📽️': Icons.videocam, '📽': Icons.videocam,
    '🔊': Icons.volume_up,
    '🔉': Icons.volume_down,
    '🔇': Icons.volume_off,
    '📡': Icons.satellite,
    '🛜': Icons.wifi,
    '📶': Icons.signal_cellular_alt,
    '🥄': Icons.restaurant,
    '🍴': Icons.restaurant,
    '🔪': Icons.restaurant,
    '🥢': Icons.restaurant,
    '🍶': Icons.local_drink,
    '🥃': Icons.local_bar,
    '🍾': Icons.celebration,
    '🧊': Icons.ac_unit,
    '🧂': Icons.kitchen,
    '🫖': Icons.emoji_food_beverage,
    '🍯': Icons.kitchen,
    '🥫': Icons.kitchen,
    '🧈': Icons.kitchen,
    '🧋': Icons.local_drink,
    '🧉': Icons.local_drink,
    '🍼': Icons.child_care,
    '🥣': Icons.restaurant,
    '🍱': Icons.bento,
    '🍛': Icons.restaurant,
    '🍲': Icons.soup_kitchen,
    '🥘': Icons.soup_kitchen,
    '🍳': Icons.breakfast_dining,
    '🥙': Icons.bakery_dining,
    '🥚': Icons.egg,
    '🧇': Icons.breakfast_dining,
    '🥞': Icons.breakfast_dining,
    '🧆': Icons.restaurant,
    '🥓': Icons.restaurant,
    '🥩': Icons.restaurant,
    '🍗': Icons.restaurant,
    '🍖': Icons.restaurant,
    '🦴': Icons.pets,
    '🌶️': Icons.restaurant, '🌶': Icons.restaurant,
    '🫑': Icons.restaurant,
    '🥒': Icons.restaurant,
    '🥬': Icons.restaurant,
    '🥦': Icons.restaurant,
    '🧄': Icons.restaurant,
    '🧅': Icons.restaurant,
    '🥕': Icons.restaurant,
    '🌽': Icons.restaurant,
    '🥔': Icons.restaurant,
    '🍠': Icons.restaurant,
    '🥐': Icons.bakery_dining,
    '🥖': Icons.bakery_dining,
    '🥨': Icons.bakery_dining,
    '🥯': Icons.bakery_dining,
    '🧀': Icons.restaurant,
    '🍩': Icons.donut_large,
    '🍪': Icons.cookie,
    '🎂': Icons.cake,
    '🍮': Icons.restaurant,
    '🍭': Icons.icecream,
    '🍬': Icons.icecream,
    '🍿': Icons.fastfood,
    '🥧': Icons.pie_chart,
    '🍦': Icons.icecream,
    '🍧': Icons.icecream,
    '🍨': Icons.icecream,
    '💛': Icons.favorite,
    '🤍': Icons.favorite,
    '🖤': Icons.favorite,
    '🤎': Icons.favorite,
    '💝': Icons.favorite,
    '💖': Icons.favorite,
    '✔️': Icons.check, '✔': Icons.check,
    '➕': Icons.add,
    '➖': Icons.remove,
    '✖️': Icons.close, '✖': Icons.close,
    '➗': Icons.safety_divider,
    '🆕': Icons.new_releases,
    '🆓': Icons.money_off,
    '🆙': Icons.arrow_upward,
    '🆗': Icons.check_circle_outline,
    '🆒': Icons.ac_unit,
    '🏆': Icons.emoji_events,
    '🥇': Icons.emoji_events,
    '🥈': Icons.emoji_events,
    '🥉': Icons.emoji_events,
    '🎖️': Icons.military_tech, '🎖': Icons.military_tech,
    '🏅': Icons.sports_score,
  };

  static IconData parseIcon(String? iconStr, String categoryName) {
    if (iconStr != null && iconStr.isNotEmpty) {
      // 1. Direct Emoji Map Check (Find any mapped emoji in the string)
      for (final entry in _emojiMap.entries) {
        if (iconStr.contains(entry.key)) {
          return entry.value;
        }
      }

      // 2. Keyword check on iconStr (just in case)
      final lowerStr = iconStr.toLowerCase();
      if (lowerStr.contains('wind') || lowerStr.contains('towel')) return Icons.air;
      if (lowerStr.contains('clean') || lowerStr.contains('broom') || lowerStr.contains('spray') || lowerStr.contains('sparkle')) return Icons.cleaning_services;
      if (lowerStr.contains('bed') || lowerStr.contains('sleep')) return Icons.bed;
      if (lowerStr.contains('bath') || lowerStr.contains('shower') || lowerStr.contains('tub') || lowerStr.contains('water')) return Icons.bathtub;
      if (lowerStr.contains('door') || lowerStr.contains('key')) return Icons.vpn_key;
      if (lowerStr.contains('wrench') || lowerStr.contains('build') || lowerStr.contains('tool') || lowerStr.contains('hammer') || lowerStr.contains('repair')) return Icons.build;
      if (lowerStr.contains('wifi') || lowerStr.contains('network') || lowerStr.contains('router') || lowerStr.contains('signal') || lowerStr.contains('internet')) return Icons.wifi;
      if (lowerStr.contains('tv') || lowerStr.contains('monitor') || lowerStr.contains('screen')) return Icons.tv;
      if (lowerStr.contains('power') || lowerStr.contains('plug') || lowerStr.contains('zap')) return Icons.power;
      if (lowerStr.contains('light') || lowerStr.contains('bulb')) return Icons.lightbulb_outline;
      if (lowerStr.contains('food') || lowerStr.contains('room_service') || lowerStr.contains('utensil') || lowerStr.contains('fork') || lowerStr.contains('knife') || lowerStr.contains('restaurant')) return Icons.restaurant;
      if (lowerStr.contains('coffee') || lowerStr.contains('cup') || lowerStr.contains('mug')) return Icons.local_cafe;
      if (lowerStr.contains('drink') || lowerStr.contains('glass') || lowerStr.contains('wine')) return Icons.wine_bar;
      if (lowerStr.contains('bell') || lowerStr.contains('concierge') || lowerStr.contains('ring')) return Icons.notifications;
      if (lowerStr.contains('luggage') || lowerStr.contains('bag') || lowerStr.contains('suitcase')) return Icons.luggage;
      if (lowerStr.contains('phone') || lowerStr.contains('call') || lowerStr.contains('support')) return Icons.phone;
      if (lowerStr.contains('user') || lowerStr.contains('person') || lowerStr.contains('avatar')) return Icons.person;
      if (lowerStr.contains('calendar') || lowerStr.contains('date')) return Icons.calendar_today;
      if (lowerStr.contains('car') || lowerStr.contains('taxi') || lowerStr.contains('vehicle')) return Icons.local_taxi;
      if (lowerStr.contains('plane') || lowerStr.contains('flight') || lowerStr.contains('airport')) return Icons.flight;
      if (lowerStr.contains('bus')) return Icons.directions_bus;
      if (lowerStr.contains('clock') || lowerStr.contains('time') || lowerStr.contains('watch')) return Icons.access_time;
      if (lowerStr.contains('laundry') || lowerStr.contains('shirt') || lowerStr.contains('wash')) return Icons.local_laundry_service;
      if (lowerStr.contains('heart')) return Icons.favorite;
      if (lowerStr.contains('star')) return Icons.star;
      if (lowerStr.contains('info')) return Icons.info_outline;
      if (lowerStr.contains('help') || lowerStr.contains('question')) return Icons.help_outline;
      if (lowerStr.contains('map') || lowerStr.contains('pin') || lowerStr.contains('location')) return Icons.location_on;
      if (lowerStr.contains('credit') || lowerStr.contains('card') || lowerStr.contains('pay')) return Icons.credit_card;
      if (lowerStr.contains('spa') || lowerStr.contains('massage')) return Icons.spa;
      if (lowerStr.contains('pool') || lowerStr.contains('swim')) return Icons.pool;
      if (lowerStr.contains('fitness') || lowerStr.contains('gym') || lowerStr.contains('dumbbell')) return Icons.fitness_center;
    }
    
    // 3. Fallback to Category Name
    final lowerCat = categoryName.toLowerCase();
    if (lowerCat.contains('housekeeping') || lowerCat.contains('clean')) return Icons.cleaning_services;
    if (lowerCat.contains('room service') || lowerCat.contains('food')) return Icons.room_service;
    if (lowerCat.contains('maintenance') || lowerCat.contains('repair')) return Icons.build;
    if (lowerCat.contains('plumber') || lowerCat.contains('water')) return Icons.plumbing;
    if (lowerCat.contains('electrical') || lowerCat.contains('power')) return Icons.electrical_services;
    if (lowerCat.contains('carpent') || lowerCat.contains('wood')) return Icons.handyman;
    if (lowerCat.contains('air conditioning') || lowerCat.contains('ac')) return Icons.ac_unit;
    if (lowerCat.contains('it') || lowerCat.contains('i.t') || lowerCat.contains('network') || lowerCat.contains('wifi')) return Icons.wifi;
    if (lowerCat.contains('concierge') || lowerCat.contains('luggage') || lowerCat.contains('bell')) return Icons.luggage;
    if (lowerCat.contains('reception') || lowerCat.contains('desk') || lowerCat.contains('support')) return Icons.support_agent;
    if (lowerCat.contains('guest service')) return Icons.support_agent;
    if (lowerCat.contains('laundry') || lowerCat.contains('wash')) return Icons.local_laundry_service;
    if (lowerCat.contains('health') || lowerCat.contains('safety')) return Icons.health_and_safety;
    if (lowerCat.contains('transport') || lowerCat.contains('taxi')) return Icons.local_taxi;
    
    return Icons.support_agent_outlined;
  }

  static Color parseColor(String? colorStr, String categoryName) {
    if (colorStr != null && colorStr.isNotEmpty) {
      // Tailwind class matching
      final lower = colorStr.toLowerCase();
      if (lower.contains('orange')) return Colors.orange;
      if (lower.contains('red')) return Colors.redAccent;
      if (lower.contains('blue')) return Colors.blue;
      if (lower.contains('indigo')) return Colors.indigo;
      if (lower.contains('purple')) return Colors.purple;
      if (lower.contains('teal')) return Colors.teal;
      if (lower.contains('green')) return Colors.green;
      if (lower.contains('yellow')) return Colors.amber;
      if (lower.contains('pink')) return Colors.pink;
      if (lower.contains('gray') || lower.contains('grey')) return Colors.blueGrey;

      // Hex fallback
      String hexColor = colorStr.replaceAll('#', '');
      if (hexColor.length == 6) hexColor = 'FF$hexColor';
      if (hexColor.length == 8) {
        try {
          return Color(int.parse(hexColor, radix: 16));
        } catch (_) {}
      }
    }
    
    // Fallback based on category name
    final lowerCat = categoryName.toLowerCase();
    if (lowerCat.contains('housekeeping')) return Colors.orange;
    if (lowerCat.contains('maintenance')) return Colors.lightBlue;
    if (lowerCat.contains('room service')) return Colors.redAccent;
    if (lowerCat.contains('concierge')) return Colors.indigoAccent;
    if (lowerCat.contains('i.t') || lowerCat.contains('it')) return Colors.purpleAccent;
    if (lowerCat.contains('laundry')) return Colors.blue;
    if (lowerCat.contains('reception')) return Colors.blueAccent;
    if (lowerCat.contains('plumb')) return Colors.cyan;
    if (lowerCat.contains('electric')) return Colors.amber;
    if (lowerCat.contains('air conditioning') || lowerCat.contains('ac')) return Colors.teal;
    if (lowerCat.contains('carpent')) return Colors.brown;
    
    return Colors.blueGrey;
  }
}
