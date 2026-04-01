// CalendarOverviewView.swift
// 日历概览页
// 显示月历视图，标记有训练记录的日期，点击可查看当天训练

import SwiftUI
import SwiftData

struct CalendarOverviewView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse)
    private var sessions: [WorkoutSession]
    
    // 当前显示的月份
    @State private var displayedMonth: Date = .now
    
    // 选中的日期（点击日历上的某天）
    @State private var selectedDate: Date? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ========== 月份导航栏 ==========
                    HStack {
                        Button {
                            changeMonth(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundStyle(.orange)
                        }
                        
                        Spacer()
                        
                        Text(displayedMonth, format: .dateTime.year().month(.wide))
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                            changeMonth(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    // ========== 星期标题行 ==========
                    HStack {
                        ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // ========== 日历网格 ==========
                    let days = daysInMonth()
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(days, id: \.self) { day in
                            if let day = day {
                                DayCellView(
                                    date: day,
                                    hasWorkout: hasWorkout(on: day),
                                    isSelected: isSameDay(day, selectedDate),
                                    isToday: isSameDay(day, .now),
                                    muscleGroup: muscleGroup(on: day)
                                )
                                .onTapGesture {
                                    selectedDate = day
                                }
                            } else {
                                // 空白占位（月初之前的空格）
                                Text("")
                                    .frame(height: 44)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // ========== 选中日期的训练详情 ==========
                    if let selected = selectedDate {
                        let daySessions = sessionsOn(date: selected)
                        
                        if daySessions.isEmpty {
                            VStack(spacing: 8) {
                                Text("这天没有训练记录")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 20)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(selected, format: .dateTime.month().day().weekday(.wide))
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(daySessions) { session in
                                    NavigationLink(destination: WorkoutDetailView(session: session)) {
                                        WorkoutRowView(session: session)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 12)
                        }
                    }
                    
                    // ========== 本月统计 ==========
                    let monthSessions = sessionsInCurrentMonth()
                    if !monthSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("本月统计")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "训练天数",
                                    value: "\(monthSessions.count)",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                                
                                StatCard(
                                    title: "总动作数",
                                    value: "\(monthSessions.reduce(0) { $0 + $1.exercises.count })",
                                    icon: "figure.strengthtraining.traditional",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "总组数",
                                    value: "\(monthSessions.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets.count } })",
                                    icon: "repeat",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 12)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("日历")
        }
    }
    
    // ========== 辅助方法 ==========
    
    // 切换月份（+1 下个月，-1 上个月）
    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
            selectedDate = nil
        }
    }
    
    // 生成当月的日期数组（包含月初的空白占位）
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        
        // 获取当月第一天
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: components) else { return [] }
        
        // 获取当月天数
        guard let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }
        
        // 第一天是星期几（0=Sunday）
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        
        // 构建日期数组：前面填nil（空白），后面填实际日期
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        return days
    }
    
    // 检查某天是否有训练记录
    private func hasWorkout(on date: Date) -> Bool {
        sessions.contains { isSameDay($0.date, date) }
    }
    
    // 获取某天的训练部位（用于日历上显示小标签）
    private func muscleGroup(on date: Date) -> String? {
        sessions.first { isSameDay($0.date, date) }?.muscleGroup
    }
    
    // 获取某天的所有训练
    private func sessionsOn(date: Date) -> [WorkoutSession] {
        sessions.filter { isSameDay($0.date, date) }
    }
    
    // 获取当前显示月份的所有训练
    private func sessionsInCurrentMonth() -> [WorkoutSession] {
        let calendar = Calendar.current
        return sessions.filter {
            calendar.isDate($0.date, equalTo: displayedMonth, toGranularity: .month)
        }
    }
    
    // 判断两个日期是否是同一天
    private func isSameDay(_ date1: Date, _ date2: Date?) -> Bool {
        guard let date2 = date2 else { return false }
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

// ============================================================
// MARK: - DayCellView（日历中每个日期格子）
// ============================================================
struct DayCellView: View {
    let date: Date
    let hasWorkout: Bool
    let isSelected: Bool
    let isToday: Bool
    let muscleGroup: String?
    
    var body: some View {
        VStack(spacing: 2) {
            // 日期数字
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isSelected ? .white : (isToday ? .orange : .primary))
            
            // 如果有训练，显示一个小圆点
            if hasWorkout {
                Circle()
                    .fill(isSelected ? .white : .orange)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? .orange : .clear)
        )
    }
}

// ============================================================
// MARK: - StatCard（统计卡片）
// ============================================================
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
