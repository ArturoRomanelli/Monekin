import 'package:collection/collection.dart';
import 'package:finlytics/app/home/home.page.dart';
import 'package:finlytics/core/database/services/app-data/app_data_service.dart';
import 'package:finlytics/core/database/services/currency/currency_service.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/presentation/widgets/currency_selector_modal.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  double currentPage = 0.0;
  final _pageViewController = PageController();

  introFinished() {
    AppDataService.instance
        .setAppDataItem(AppDataKey.introSeen, 'true')
        .then((value) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            )));
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    List items = [
      {
        'header': t.intro.sl1_title,
        'description': t.intro.sl1_descr,
        'image': 'assets/icons/app_onboarding/first.svg'
      },
      {
        'header': t.intro.sl2_title,
        'description': t.intro.sl2_descr,
        'description2': t.intro.sl2_descr2,
        'image': 'assets/icons/app_onboarding/security.svg'
      },
      {
        'header': t.backup.import.title,
        'description': t.backup.import.long_description,
        'image': 'assets/icons/app_onboarding/upload.svg'
      },
      {
        'header': t.intro.last_slide_title,
        'description': t.intro.last_slide_descr,
        'description2': t.intro.last_slide_descr2,
        'image': 'assets/icons/app_onboarding/wallet.svg'
      },
    ];

    List<Widget> slides = items
        .mapIndexed((index, item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: SvgPicture.asset(
                    item['image'],
                    fit: BoxFit.fitWidth,
                    width: 240.0,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                const SizedBox(height: 120),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['header'],
                            style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 20),
                        Text(
                          item['description'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        if (item['description2'] != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            item['description2'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                        if (index == 0) ...[
                          const SizedBox(height: 40),
                          FutureBuilder(
                              future: CurrencyService.instance
                                  .getUserPreferredCurrency(),
                              builder: (context, snapshot) {
                                final userCurrency = snapshot.data;

                                return ListTile(
                                  tileColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.04),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.45),
                                  ),
                                  leading: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: userCurrency != null
                                        ? userCurrency.displayFlagIcon(size: 42)
                                        : const Skeleton(height: 42, width: 42),
                                  ),
                                  title: Text(t.intro.select_your_currency),
                                  subtitle: userCurrency != null
                                      ? Text(userCurrency.name)
                                      : const Skeleton(height: 12, width: 50),
                                  onTap: () {
                                    if (userCurrency == null) return;

                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        showDragHandle: true,
                                        builder: (context) {
                                          return CurrencySelectorModal(
                                              preselectedCurrency: userCurrency,
                                              onCurrencySelected:
                                                  (newCurrency) {
                                                UserSettingService.instance
                                                    .setSetting(
                                                        SettingKey
                                                            .preferredCurrency,
                                                        newCurrency.code)
                                                    .then((value) =>
                                                        setState(() => {}));
                                              });
                                        });
                                  },
                                );
                              }),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            )))
        .toList();

    List<Widget> indicator() => List<Widget>.generate(
        slides.length,
        (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              height: 10.0,
              width: 10.0,
              decoration: BoxDecoration(
                  color: currentPage.round() == index
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0)),
            ));

    bool isLastPage = currentPage == slides.length - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      persistentFooterButtons: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SizedBox(
                  child: !isLastPage
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                                onPressed: () => introFinished(),
                                child: Text(t.intro.skip, softWrap: false)),
                          ],
                        )
                      : Container(),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: indicator(),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextButton.icon(
                          onPressed: () {
                            if (isLastPage) {
                              introFinished();

                              return;
                            }

                            _pageViewController.nextPage(
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.bounceIn);
                          },
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            semanticLabel: t.general.continue_text,
                          ),
                          label: Text(t.intro.next, softWrap: false)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
      body: PageView.builder(
        controller: _pageViewController,
        physics: const BouncingScrollPhysics(),
        pageSnapping: true,
        itemCount: slides.length,
        itemBuilder: (BuildContext context, int index) {
          _pageViewController.addListener(() {
            if (_pageViewController.page == null) return;

            setState(() {
              currentPage = _pageViewController.page!;
            });
          });

          return slides[index];
        },
      ),
    );
  }
}
