import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'locales/ar_sa.dart';
import 'locales/de_de.dart';
import 'locales/en_us.dart';
import 'locales/es_es.dart';
import 'locales/fr_fr.dart';
import 'locales/hi_in.dart';
import 'locales/id_id.dart';
import 'locales/it_it.dart';
import 'locales/ja_jp.dart';
import 'locales/ko_kr.dart';
import 'locales/pt_br.dart';
import 'locales/ru_ru.dart';
import 'locales/tr_tr.dart';
import 'locales/ur_pk.dart';
import 'locales/zh_cn.dart';

/// GetX translation registry. New international locale files plug in here.
class AppTranslations extends Translations {
  static const supportedLocales = <Locale>[
    Locale('en', 'US'),
    Locale('ar', 'SA'),
    Locale('fr', 'FR'),
    Locale('ur', 'PK'),
    Locale('es', 'ES'),
    Locale('de', 'DE'),
    Locale('it', 'IT'),
    Locale('pt', 'BR'),
    Locale('tr', 'TR'),
    Locale('hi', 'IN'),
    Locale('id', 'ID'),
    Locale('ru', 'RU'),
    Locale('zh', 'CN'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
  ];

  @override
  Map<String, Map<String, String>> get keys => const {
    'en_US': enUs,
    'ar_SA': arSa,
    'fr_FR': frFr,
    'ur_PK': urPk,
    'es_ES': esEs,
    'de_DE': deDe,
    'it_IT': itIt,
    'pt_BR': ptBr,
    'tr_TR': trTr,
    'hi_IN': hiIn,
    'id_ID': idId,
    'ru_RU': ruRu,
    'zh_CN': zhCn,
    'ja_JP': jaJp,
    'ko_KR': koKr,
  };
}
