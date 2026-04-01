// ContentView.swift
// 主界面 - 使用 TabView 组织两个页面：训练列表 和 日历视图

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab 1: 训练记录列表（按时间倒序）
            WorkoutListView()
                .tabItem {
                    Label("训练", systemImage: "dumbbell.fill")
                }
            
            // Tab 2: 日历概览（可以看到哪天练了什么）
            CalendarOverviewView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
        }
        .tint(.orange) // 全局主题色：橙色，代表力量和活力
    }
}
