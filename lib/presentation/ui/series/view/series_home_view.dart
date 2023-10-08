import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iptv_part/presentation/resources/values_manager.dart';
import '../../../../domain/models/route_screen_model.dart';
import '../../../../domain/responses/category_response.dart';
import '../../../../domain/responses/serie_response.dart';
import '../../../../domain/services/serie_services.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/color_manager.dart';
import '../../../resources/constants_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import '../../../widgets/filter_widget.dart';
import '../../../widgets/waiting_widget.dart';
import '../viewmodel/series_home_viewmodel.dart';


// ignore: must_be_immutable
class SeriesHomeView extends StatefulWidget {

  String nameSlider;

  SeriesHomeView({
    required this.nameSlider,
    super.key,
  });

  @override
  _SeriesHomeViewState createState() => _SeriesHomeViewState();
}

class _SeriesHomeViewState extends State<SeriesHomeView> {
  late SeriesHomeViewModel _viewModel;
  RouteScreenModel screenModel = RouteScreenModel();
  String bgImage = "";
  int _selectedNavbarItemIndex = 0;
  int _selectedSliderIndex = -1;
  int _selectedFilterIndex = 0;
  final int _crossAxisCount = 4;
  late List<dynamic> listOfUnderCategories = [];
  late Map<String, List<EpisodeModel>> mapSerieAndEpisode = {};
  bool _showMenuFilter = false;
  int _menuLevel = 0;
  List<String> _listFilterValues = [];
  Map<String, String> _menuChosenValues = {};
  late ScrollController _scrollSlidersController,
      _scrollFilterController,
      _scrollNavbarController;
  late FocusNode _rawMainFocusNode;
  late List<FocusNode> _navbarItemsFocusNode;
  int _focusedPartScreen = 0;

  String _filterKey = "";

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _showMenuFilter = false;
    _menuLevel = 0;
    _scrollSlidersController = ScrollController();
    _scrollFilterController = ScrollController();
    _scrollNavbarController = ScrollController();
    _rawMainFocusNode = FocusNode();

    _viewModel = SeriesHomeViewModel();
    _viewModel.start();
    _listFilterValues = AppConstants.menusFilterValue;
    _viewModel.seriesRouteDataStream.listen((seriesScreen) {
      // final list = moviesScreen.;
      setState(() {
        screenModel = seriesScreen;
        bgImage = seriesScreen.backgroundImage!;
        _selectedNavbarItemIndex = seriesScreen.indexNavbarClicked;
        _selectedSliderIndex = seriesScreen.indexSliderClicked;
        listOfUnderCategories = seriesScreen.listOfBodyItems ?? [];
      });
    });
      _navbarItemsFocusNode = List.generate(
        20,
            (index) => FocusNode(),
      );
      print("_navbarItemsFocusNode = $_navbarItemsFocusNode");

    _viewModel.selectedFilterIndex.listen((index) {
      setState(() {
        if (_selectedFilterIndex == index) {
          if (_menuLevel == 0 && _selectedFilterIndex != 2) {
            _menuLevel = 1;
          } else {
            _menuLevel = 0;
          }
          if (_menuLevel == 1) {
            if (_selectedFilterIndex == 0) {
              _listFilterValues = _viewModel.listYears;
              // print("_menuChosenValues[_selectedFilterIndex] = ${_menuChosenValues[_selectedFilterIndex]}");
            } else if (_selectedFilterIndex == 1) {
              _listFilterValues = _viewModel.listGenres;
            } else if (_selectedFilterIndex == 3) {
              _listFilterValues = AppConstants.menusOrderValue;
            }
          } /*else {
            _listFilterValues = AppConstants.menusFilterValue;
          }*/
        }
        _selectedFilterIndex = index;
      });
    });

    _viewModel.getMapSeasonsEpisodes.listen((serieAndEpisodeMap) {
      setState(() {
        // bgImage = _viewModel.listSliders[index].backgroundImage;
        mapSerieAndEpisode = serieAndEpisodeMap;
      });
    });
    _viewModel.getMenuChosenValues.listen((menu) {
      setState(() {
        _menuChosenValues = menu;
      });
    });
    _handleNavbarSelection(0);
  }

  void _toggleMenu() {
    setState(() {
      _showMenuFilter = !_showMenuFilter;
      print("_showMenu = $_showMenuFilter");
      _menuLevel = 0;
      _selectedFilterIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onPopScope(),
      child: GestureDetector(
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          if (_showMenuFilter == true) {
            _toggleMenu();
          }
        },
        child: Scaffold(
          body: StreamBuilder<RouteScreenModel>(
            stream: _viewModel.seriesRouteDataStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Use the home data from the snapshot to build the UI
                final screenData = snapshot.data!;
                return RawKeyboardListener(
                  focusNode: _rawMainFocusNode,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        if (_focusedPartScreen == 1) {
                          if (_showMenuFilter) {
                            _handleFilterSelection(-1);
                          } else {
                            setState(() {
                              _focusedPartScreen = 0;
                            });
                            _handleNavbarSelection(0);
                          }
                        } else if (_focusedPartScreen == 2) {
                          if (_selectedSliderIndex >= _crossAxisCount) {
                            _handleSliderSelection(-_crossAxisCount);
                          } else {
                            setState(() {
                              _focusedPartScreen = 1;
                            });
                            _handleFilterSelection(0);
                          }
                        }
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowDown) {
                        if (_focusedPartScreen == 0) {
                          setState(() {
                            _focusedPartScreen = 1;
                          });
                          _handleFilterSelection(0);
                        } else if (_focusedPartScreen == 1) {
                          if (_showMenuFilter) {
                            _handleFilterSelection(1);
                          } else {
                            setState(() {
                              _focusedPartScreen = 2;
                            });
                            _handleSliderSelection(0);
                          }
                        } else if (_focusedPartScreen == 2) {
                          _handleSliderSelection(_crossAxisCount);
                        }
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowRight) {
                        if (_focusedPartScreen == 0) {
                          _handleNavbarSelection(1);
                        } else if (_focusedPartScreen == 2) {
                          _handleSliderSelection(1);
                        }
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowLeft) {
                        if (_focusedPartScreen == 0) {
                          _handleNavbarSelection(-1);
                        } else if (_focusedPartScreen == 2) {
                          _handleSliderSelection(-1);
                        }
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.select) {
                        if (_focusedPartScreen == 0) {
                          _handleNavbarSelect();
                        } else if (_focusedPartScreen == 1) {
                          if (_showMenuFilter) {
                            _handleFilterSelect();
                          } else {
                            _handleFilterSelection(0);
                            _toggleMenu();
                          }
                        } else if (_focusedPartScreen == 2) {
                          _handleSliderSelect();
                        }
                      }
                    }
                  },
                  child:Stack(
                    children: [
                        bgImage == AssetsManager.bgSeries
                            ? Image.asset(
                                bgImage,
                                fit: BoxFit.fill,
                                height: double.infinity,
                                width: double.infinity,
                              )
                            : Image.network(
                                bgImage,
                                fit: BoxFit.fill,
                                height: double.infinity,
                                width: double.infinity,
                              ),
                        FilterWidget(
                          marginVertical:4,
                          marginHorizontal: Get.height * .15,
                          toggleMenu: _toggleMenu,
                          isFocused: _focusedPartScreen == 1,
                          // filterBtnNode: _filterButtonFocusNode,
                        ),
                      
                         Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                color: Colors.black,
                              ),
                              width: Get.width * .20,
                              child: ListView.builder(
                                controller: _scrollNavbarController,
                                scrollDirection: Axis.vertical,
                                itemCount: _viewModel.navbarList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding:const EdgeInsets.only(top: 15),
                                  child: TextButton(
                                    focusNode: _navbarItemsFocusNode[
                                        _selectedNavbarItemIndex],
                                    onPressed: () {
                                      final itemClicked =
                                      _viewModel.navbarList[index];

                                      screenData.categoryChoosen =
                                          itemClicked.name;

                                      Future<dynamic> function;

                                      function = serieService
                                          .getAllSeries();

                                      _viewModel.onNavbarItemClicked(
                                        index,
                                        function,
                                        // widget.nameSlider,
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      backgroundColor: _selectedNavbarItemIndex ==
                                              index
                                          ? _focusedPartScreen == 0
                                              ? ColorManager.white
                                              : ColorManager.white
                                                  .withOpacity(0.3)
                                          : ColorManager.transparent,
                                      foregroundColor: ColorManager.transparent,
                                      shape: const RoundedRectangleBorder(
                                          side: BorderSide.none),
                                    ),
                                    child: Text(
                                      _viewModel.navbarList[index].name,
                                      style: getBoldStyle(
                                        color: _selectedNavbarItemIndex == index
                                            ? _focusedPartScreen == 0
                                                ? ColorManager.black
                                                : ColorManager.black
                                                    .withOpacity(0.3)
                                            : _focusedPartScreen == 0
                                                ? ColorManager.white
                                                : ColorManager.black
                                                    .withOpacity(0.3),
                                        fontSize: FontSize.s16,
                                      ),
                                    ),
                                  ));
                                },
                              ),
                            ),
                          ),
                          Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: Get.height * .2,
                            ),
                            width: Get.width * .79,
                            height: Get.height * .9,
                            child: GridView.builder(
                              controller: _scrollSlidersController,
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _crossAxisCount,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: Get.width * .02,
                                mainAxisSpacing: Get.height * .04,
                              ),
                              itemCount: listOfUnderCategories.length,
                              itemBuilder: (BuildContext context, int index) {
                                final slider = listOfUnderCategories[index];
                                screenData.listOfBodyItems =
                                    listOfUnderCategories;
                                String? yearOfMovie =
                                    slider.date.toString().split('-')[0];
                                return GestureDetector(
                                  onTap: () {
                                    _viewModel.onSliderClicked(index, slider);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    curve: Curves.easeInOut,
                                    height: Get.height * .32,
                                    width: Get.width * 0.3,
                                    decoration: BoxDecoration(
                                      color: _selectedSliderIndex == index
                                          ? ColorManager.darkPrimary
                                          : ColorManager.white,
                                      boxShadow: _selectedSliderIndex == index
                                          ? [
                                              const BoxShadow(
                                                color: Colors.blue,
                                                spreadRadius: 3,
                                                blurRadius: 2,
                                                offset: Offset(0, 0),
                                              ),
                                            ]
                                          : null,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                          decoration: BoxDecoration(
                                            color: _selectedSliderIndex == index
                                                ? null
                                                : ColorManager.black,
                                          ),
                                          height: Get.height * .32,
                                          width: Get.width * 0.3,
                                          child: ClipRRect(
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  AssetsManager.alphaLogo,
                                                  fit: BoxFit.fill,
                                                ),
                                                Image.network(
                                                  slider.icon,
                                                  width: 700,
                                                  fit: BoxFit.fill,
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: 
                                                 Container(
                                                    decoration: BoxDecoration(
                                                      color: ColorManager.black,
                                                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15))
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(AppPadding.p8),
                                                    child: Text(
                                                      yearOfMovie,
                                                      style: getBoldStyle(
                                                        color:
                                                            ColorManager.white,
                                                        fontSize: FontSize.s18,
                                                      ),
                                                    ),
                                                  ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        )
                                        ),
                                        Expanded(
                                          flex:2,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                child: Text(
                                                  slider.name,
                                                  overflow: TextOverflow.clip,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: FontSize.s14,
                                                    color:
                                                        _selectedSliderIndex ==
                                                                index
                                                            ? ColorManager.white
                                                            : ColorManager
                                                                .black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                          Align(
                          alignment: Alignment.topRight,
                          child: Visibility(
                            visible: _showMenuFilter,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                color: ColorManager.black,
                              ),
                              width: Get.width * .3,
                              height: Get.height,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: _menuLevel == 0 ? 15 : 0),
                                  _menuLevel == 0
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .015),
                                            const Icon(
                                              Icons.filter_list,
                                              color: Colors.white,
                                              size: FontSize.s40,
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .025),
                                            Text(
                                              "Filter",
                                              style: getSemiBoldStyle(
                                                  color: ColorManager.white,
                                                  fontSize: FontSize.s30),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(height: Get.height * .01),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: _scrollFilterController,
                                      scrollDirection: Axis.vertical,
                                      itemCount: _menuLevel == 0
                                          ? AppConstants.menusFilterKey.length
                                          : _listFilterValues.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: index ==
                                                        _selectedFilterIndex &&
                                                    _menuLevel == 0
                                                ? LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      ColorManager
                                                          .selectedNavBarItem,
                                                      Colors.transparent
                                                    ],
                                                  )
                                                : null,
                                            color:
                                                index == _selectedFilterIndex &&
                                                        _menuLevel == 1
                                                    ? ColorManager.lightGrey
                                                    : null,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: TextButton(
                                            // focusNode: _filterValuesFocusNode[_selectedFilterIndex],
                                            onPressed: () {
                                              if (_menuLevel == 0) {
                                                _filterKey = AppConstants
                                                    .menusFilterKey[index];
                                              } else {
                                                _menuChosenValues[_filterKey] =
                                                    _listFilterValues[index];
                                              }
                                              _viewModel.onFilterClicked(
                                                index,
                                                _selectedFilterIndex == index,
                                              );
                                            },
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: _menuLevel == 0
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          AppConstants
                                                                  .menusFilterKey[
                                                              index],
                                                          style: getRegularStyle(
                                                              color:
                                                                  ColorManager
                                                                      .white,
                                                              fontSize:
                                                                  FontSize.s22),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          _menuChosenValues[
                                                                  AppConstants
                                                                          .menusFilterKey[
                                                                      index]] ??
                                                              AppConstants
                                                                      .menusFilterValue[
                                                                  index],
                                                          style: getRegularStyle(
                                                              color: _menuChosenValues[
                                                                          AppConstants.menusFilterKey[
                                                                              index]] ==
                                                                      AppConstants
                                                                              .menusFilterValue[
                                                                          index]
                                                                  ? ColorManager
                                                                      .lightGrey
                                                                  : ColorManager
                                                                      .selectedNavBarItem,
                                                              fontSize:
                                                                  FontSize.s12),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      _listFilterValues[index],
                                                      style: getRegularStyle(
                                                          color: ColorManager
                                                              .white,
                                                          fontSize:
                                                              FontSize.s16),
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  _menuLevel == 0
                                      ? Align(
                                          alignment: Alignment.bottomCenter,
                                          child: GestureDetector(
                                            onTap: () {
                                              _toggleMenu();
                                              _viewModel.onApplyFilter(
                                                  _menuChosenValues);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(15)
                                                ),
                                                 color: _selectedFilterIndex ==
                                                      AppConstants
                                                          .menusFilterKey.length
                                                  ? ColorManager
                                                      .selectedNavBarItem
                                                  : ColorManager.white,
                                              ),
                                              margin: EdgeInsets.only(
                                                bottom: Get.height * .07,
                                              ),
                                           
                                              width: Get.width*0.2,
                                              height: Get.height * .1,
                                              child: Center(
                                                child: Text(
                                                  "APPLY FILTERS",
                                                  style: getBoldStyle(
                                                      color: _selectedFilterIndex ==
                                                              AppConstants
                                                                  .menusFilterKey
                                                                  .length
                                                          ? ColorManager.white
                                                          : ColorManager
                                                              .darkPrimary,
                                                      fontSize: FontSize.s18),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                     
                );
              } else if (snapshot.hasError) {
                return const Text('Error loading home data');
              } else {
                // return const Center(child: CircularProgressIndicator());
                return WaitingWidget(title: widget.nameSlider);
              }
            },
          ),
        ),
      ),
    );
  }

  void _handleNavbarSelection(int direction) {
    if (direction == 0) {
      setState(() {
        _selectedNavbarItemIndex = 0;
        _selectedSliderIndex = -1;
      });
      _navbarItemsFocusNode[_selectedNavbarItemIndex].requestFocus();
      _viewModel.scrollNavbarToSelected(
          _selectedNavbarItemIndex, _scrollNavbarController);
      return;
    } else if (_selectedNavbarItemIndex + direction >= 0 &&
        _selectedNavbarItemIndex + direction <
            screenModel.navbarItems!.length) {
      _navbarItemsFocusNode[_selectedNavbarItemIndex].unfocus();

      setState(() {
        _selectedNavbarItemIndex += direction;
        screenModel.indexNavbarClicked = _selectedNavbarItemIndex;
      });
      _navbarItemsFocusNode[_selectedNavbarItemIndex].requestFocus();
      _viewModel.scrollNavbarToSelected(
          _selectedNavbarItemIndex, _scrollNavbarController);
    }
  }

  void _handleFilterSelection(int direction) {
    if (direction == 0) {
      setState(() {
        _selectedSliderIndex = -1;
        // _viewModel.onFilterClicked(0, false);
        _menuLevel = 0;
      });
      _navbarItemsFocusNode.map((e) => e.unfocus());
      // _filterValuesFocusNode[0].requestFocus();
      if (_menuLevel == 1) {
        // _filterValuesFocusNode[0].requestFocus();
        _viewModel.scrollFilterToSelected(
          0,
          _scrollFilterController,
        );
      }
    } else if (_menuLevel == 0) {
      if (_selectedFilterIndex + direction >= 0 &&
          _selectedFilterIndex + direction <=
              AppConstants.menusFilterValue.length) {
        _viewModel.onFilterClicked(_selectedFilterIndex + direction, false);
      }
    } else if (_menuLevel == 1) {
      if (_selectedFilterIndex + direction >= 0 &&
          _selectedFilterIndex + direction < _listFilterValues.length) {
        _viewModel.onFilterClicked(_selectedFilterIndex + direction, false);
      }
      _viewModel.scrollFilterToSelected(
        _selectedFilterIndex,
        _scrollFilterController,
      );
    }
  }

  void _handleSliderSelection(int direction) {
    if (direction == 0) {
      setState(() {
        _selectedSliderIndex = 0;
      });
      _navbarItemsFocusNode.map((e) => e.unfocus());
    } else if (_selectedSliderIndex + direction >= 0 &&
        _selectedSliderIndex + direction <
            screenModel.listOfBodyItems!.length) {
      setState(() {
        _selectedSliderIndex += direction;
        screenModel.indexSliderClicked = _selectedSliderIndex;
      });
    }
    _viewModel.scrollSlidersToSelected(
        _selectedSliderIndex, _scrollSlidersController, _crossAxisCount);
  }

  void _handleNavbarSelect() {
    final itemClicked = _viewModel.navbarList[_selectedNavbarItemIndex];

    Future<dynamic> function;

    function = serieService.getAllSeries();

    _viewModel.onNavbarItemClicked(
      _selectedNavbarItemIndex,
      function,
      // widget.nameSlider,
    );
    _viewModel.scrollSlidersToSelected(
        0, _scrollSlidersController, _crossAxisCount);
  }

  void _handleFilterSelect() {
    if (_menuLevel == 0 &&
        _selectedFilterIndex == AppConstants.menusFilterKey.length) {
      _toggleMenu();
      _viewModel.onApplyFilter(_menuChosenValues);
    } else {
      print("_menuLevel = $_menuLevel");
      if (_menuLevel == 0) {
        _filterKey = AppConstants.menusFilterKey[_selectedFilterIndex];

        _handleFilterSelection(0);
      } else {
        _menuChosenValues[_filterKey] = _listFilterValues[_selectedFilterIndex];
      }
      _viewModel.onFilterClicked(_selectedFilterIndex, true);
    }
  }

  void _handleSliderSelect() {
    _viewModel.onSliderClicked(_selectedSliderIndex,
        screenModel.listOfBodyItems![_selectedSliderIndex]);
  }

  Future<bool> _onPopScope() async {
    if (_showMenuFilter) {
      if (_menuLevel == 1) {
        setState(() {
          _menuLevel = 0;
        });
      } else {
        _toggleMenu();
      }
    } else {
      return true;
    }
    // Otherwise, don't close the app.
    return false;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _scrollFilterController.dispose();
    _scrollSlidersController.dispose();
    _scrollNavbarController.dispose();
    super.dispose();
  }
}

