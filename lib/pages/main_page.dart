import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mung_flutter/data/net/http_base.dart';
import 'package:mung_flutter/data/net/http_movie.dart';
import 'package:mung_flutter/model/hot_model.dart';
import 'package:mung_flutter/model/loading_state.dart';
import 'package:mung_flutter/style/base_style.dart';
import 'package:mung_flutter/style/colors.dart';
import 'package:mung_flutter/utils/route_util.dart';
import 'package:mung_flutter/utils/ui_util.dart';
import 'package:mung_flutter/widget/loading_footer_widget.dart';
import 'package:mung_flutter/widget/loading_widget.dart';
import 'package:mung_flutter/data/const/constant.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainState();
  }
}

// note: 一般StatefulWidget使用State直接以 XXState命名即可,
// 如 MainPageState, 类名前加 "_" 相当于 java的private, 但范围略大一点, 仅在一个文件内是可见
class _MainState extends State<MainPage> {

  bool _scrollRefreshing = false;
  int _start = 0;
  List<HotSubjectsModel> _hotMovieItems = [];
  final double _gridGapWidth = 10;
  LoadingState _loadingState = LoadingState.Loading;
  final ScrollController _scrollController = ScrollController();

  _requestData() {

    if (_scrollRefreshing || _loadingState == LoadingState.NoMore) return;
    
    setState(() {
      _loadingState = LoadingState.Loading;
      _scrollRefreshing = true;
    });

    HttpMovie.requestMovieHot(_start+2,20)
        .then((result){
          HotModel hotModel = HotModel.fromJson(result);
          if (hotModel.code == CODE_SUCCESS && hotModel.subjects != null) {
            setState(() {
              _scrollRefreshing = false;
              _start = hotModel.start;
              _loadingState = hotModel.subjects.length != 20 ? LoadingState.NoMore : LoadingState.Loading;
              _hotMovieItems.addAll(hotModel.subjects);
            });
          } else {
            setState(() {
              _scrollRefreshing = false;
              _loadingState = LoadingState.Error;
            });
          }
        });
  }

  @override
  void initState() {
    super.initState();

    this._requestData();

    _scrollController.addListener((){
      // 如果错误要手动单机重新加载
      if (_loadingState != LoadingState.Error &&
          _loadingState != LoadingState.NoMore) {
        double _curHeight = _scrollController.position.pixels;
        double _maxHeight = _scrollController.position.maxScrollExtent;
        if (_curHeight+loadingFooterHeight*0.8 > _maxHeight) {
          this._requestData();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

     // 有个时间差，就是执行顺序问
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.green,
          scaffoldBackgroundColor: WColors.color_f5
        ),
        home: Builder(
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
//                  leading: BaseStyle.getIconFontButton(
//                      0xeaec, () => RouteUtil.routeToThemePage(context)),
                  title: Text("Mung", style: BaseStyle.textStyleWhite(18),),
                  centerTitle: true,
                  actions: <Widget>[ BaseStyle.getIconFontButton(0xeafe, () => RouteUtil.routeToSearchPage(context))],
                ),
                body: _hotMovieItems.length == 0 ?
                LoadingWidget(_loadingState,this._requestData):
                Padding(
                  padding: EdgeInsets.only(
                      left: _gridGapWidth,
                      right: _gridGapWidth,
                      top: _gridGapWidth,
                      bottom: UiUtil.getSafeBottomPadding(context)
                  ),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: _BannerWidget(_hotMovieItems.take(4).toList()),
                      ),
                      _getCateWidget(context),
                      _getGridViewWidget(context, _hotMovieItems.skip(4).toList()),
                      SliverToBoxAdapter(
                          child: LoadingFooterWidget(_loadingState,this._requestData)
                      )
                    ],
                  ),
                ),
              );
            }
        )
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  SliverToBoxAdapter _getCateWidget(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6)
        ),
        margin: EdgeInsets.symmetric(vertical: _gridGapWidth),
        child: Row(
          children: Constant.CateItems.map((item){
            return Expanded(
                child: FlatButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: (){
                    RouteUtil.routeToListPage(context,item['title']);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(item['colors'][0]),Color(item['colors'][1])],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter
                            ),
                            borderRadius: BorderRadius.circular(19)
                        ),
                        child: Icon(
                          IconData(item['icon'],fontFamily: 'iconfont'),
                          size: 26,
                          color: WColors.color_ff,
                        ),
                      ),
                      Text(item['title'],style: TextStyle(
                        fontSize: 14,
                        color: WColors.color_ff,
                        fontWeight: FontWeight.bold
                      ))
                    ],
                  ),
                )
            );
          }).toList(),
        ),
      ),
    );
  }

  SliverGrid _getGridViewWidget(BuildContext context, List<HotSubjectsModel> _hotItems) {

    double itemWidth = (UiUtil.getDeviceWidth(context) - _gridGapWidth*4)/3;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: _gridGapWidth,
          crossAxisSpacing: _gridGapWidth,
          childAspectRatio: 3/5
      ),

      delegate: SliverChildBuilderDelegate((context,index){
        HotSubjectsModel model = _hotItems[index];
        return FlatButton(
            padding: const EdgeInsets.all(0),
            onPressed: (){
              RouteUtil.routeToDetailPage(context, model.id);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: 0,bottom: 0,left: 0,right: 0,
                      child: Image.network(
                        model.largeImage,
                        fit: BoxFit.fill,
                      )
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: itemWidth,
                                child: Text(
                                  model.title,
                                  textAlign: TextAlign.center,
                                  style: BaseStyle.textStyleWhite(12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              BaseStyle.starWidgetAndText(model.ratingAverage, 14,true)
                            ]
                        ),
                      )
                  )
                ],
              ),
            )
        );
      },childCount: _hotItems.length),
    );
  }

}

class _BannerWidget extends StatelessWidget {

  final List<HotSubjectsModel> _hotItems;

  _BannerWidget(this._hotItems);

  List<Widget> _getDotView(int activeIndex) {
    int tempIndex = 4;
    return _hotItems.map((model){
      tempIndex = tempIndex - 1;
      return Container(
        width: 16,
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: activeIndex == tempIndex ? WColors.color_ff : WColors.color_66,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    //限制行数和越界问题
    double bannerLeftWidth = UiUtil.getDeviceWidth(context) - 10*2 - 12*3 - 178*0.68;

    return Container(
      height: 200,
      child: Swiper(
        itemCount: _hotItems.length,
        itemBuilder: (BuildContext context,int index){
          HotSubjectsModel _model = _hotItems[index];
          return FlatButton(
              padding: const EdgeInsets.all(0),
              onPressed: (){
                RouteUtil.routeToDetailPage(context, _model.id);
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Theme.of(context).primaryColor
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: BaseStyle.clipRRectImg(_model.largeImage, 178*0.68, 178, 4)
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          BaseStyle.limitLineText(bannerLeftWidth, _model.title, BaseStyle.textStyleWhite(16), 1),
                          Row(
                            children: <Widget>[
                              BaseStyle.clipOvalImg(_model.avatarsSmall, 26),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: BaseStyle.limitLineText(bannerLeftWidth - 36 , _model.directorsName, BaseStyle.textStyleWhite(14),1),
                              )
                            ],
                          ),
                          BaseStyle.limitLineText(bannerLeftWidth, '主演: '+_model.castNames, BaseStyle.textStyleWhite(14), 2),
                          BaseStyle.limitLineText(bannerLeftWidth, _model.collectCount.toString()+" 看过" , BaseStyle.textStyleWhite(14), 1),
                          BaseStyle.starWidgetAndText(_model.ratingAverage, 20)
                        ],
                      ),
                    )
                  ],
                ),
              )
          );
        },
        autoplay: true,
        autoplayDelay: 4000,
        duration: 100, //圆角过度很丑，减到人察觉不到的时间差
        pagination: SwiperCustomPagination(
            builder:(BuildContext context, SwiperPluginConfig config){
              return Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(10),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: _getDotView(config.activeIndex),
                )
              );
            },
        ),
      ),
    );
  }

}