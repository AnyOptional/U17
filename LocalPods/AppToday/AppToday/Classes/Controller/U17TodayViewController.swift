//
//  U17TodayViewController.swift
//  AppToday
//
//  Created by Archer on 2018/11/20.
//

import Fate
import FOLDin
import Mediator
import Timepiece
import TYPagerController

class U17TodayViewController: TYTabPagerController {
    
    /// 使用FDNavigationBar替换系统的UINavigationBar
    override var prefersNavigationBarStyle: UINavigationBarStyle {
        return .custom
    }
    
    private lazy var searchButton: UIButton = {
        let v = UIButton()
        v.setBackgroundImage(UIImage(nameInBundle: "home_page_search"), for: .normal)
        v.sizeToFit()
        return v
    }()    
    
    private lazy var weekdayMapper: [(weekday: String, description: String)] = {
        let converter = [1 : "周日", 2 : "周一", 3 : "周二", 4 : "周三",
                         5 : "周四", 6 : "周五", 7 : "周六"]
        var mapper = [(weekday: String, description: String)]()
        let nowDate = Date()
        for i in 1..<8 {
            // 每周从周末开始
            var weekday = (nowDate.weekday + i) % 7
            if weekday == 0 { weekday = 7 - weekday }
            var description = converter[weekday]
            if i == 6 {
                description = "昨天"
            } else if i == 7 {
                description = "今天"
            }
            // 传递的又是从1-7对应周一 -> 周日
            weekday = weekday - 1
            if weekday == 0 { weekday = 7 }
            
            mapper.append((weekday: weekday.toString(), description: description!))
        }
        return mapper
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        buildNavbar()
        performBinding()
    }
    
    deinit { NSLog("\(className()) is deallocating...") }
}

extension U17TodayViewController {
    private func performBinding() {
        searchButton.rx.tap
            .subscribeNext(weak: self) { (self) in
                return { _ in
                    if let vc = Mediator.getSearchViewController() {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
        }.disposed(by: disposeBag)
    }
}

extension U17TodayViewController: TYTabPagerControllerDelegate, TYTabPagerControllerDataSource {
    func numberOfControllersInTabPagerController() -> Int {
        return weekdayMapper.count
    }
    
    func tabPagerController(_ tabPagerController: TYTabPagerController, controllerFor index: Int, prefetching: Bool) -> UIViewController {
        let vc = TodayListViewController()
        vc.isFirstPage = (index == 0)
        vc.weekday = weekdayMapper[index].weekday
        vc.reactor = TodayListViewReactor()
        return vc
    }
    
    func tabPagerController(_ tabPagerController: TYTabPagerController, titleFor index: Int) -> String {
        return weekdayMapper[index].description
    }
}

extension U17TodayViewController {
    private func buildNavbar() {
        fd.navigationItem.title = "今日更新"
        fd.navigationItem.rightBarButtonItem = FDBarButtonItem(customView: searchButton)
    }
    
    private func buildUI() {
        automaticallyAdjustsScrollViewInsets = false
        tabBarHeight = 50
        tabBarOrignY = fd.fullNavbarHeight
        layout.addVisibleItemOnlyWhenScrollAnimatedEnd = true
        tabBar.layout.barStyle = .progressBounceView
        tabBar.layout.progressVerEdging = 3
        tabBar.layout.progressColor = U17def.green_30DC91
        tabBar.layout.normalTextColor = U17def.black_666666
        tabBar.layout.selectedTextColor = U17def.green_30DC91
        tabBar.layout.normalTextFont = UIFont.systemFont(ofSize: 14)
        tabBar.layout.selectedTextFont = UIFont.systemFont(ofSize: 14)
        tabBar.layout.textColorProgressEnable = true
        tabBar.layout.cellWidth = (view.width - 140) / 7
        tabBar.layout.cellSpacing = 0
        tabBar.layout.cellEdging = 10
        tabBar.layout.adjustContentCellsCenter = true
        dataSource = self
        delegate = self
        
        scrollToController(at: weekdayMapper.count - 1, animate: true)
        reloadData()
    }
}
