// WorkoutListView.swift
// 训练记录列表页
// 显示所有训练日，按日期倒序排列，支持新增和删除

import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 从 SwiftData 查询所有训练日，按日期倒序排列
    @Query(sort: \WorkoutSession.date, order: .reverse)
    private var sessions: [WorkoutSession]
    
    // 控制新建训练的弹窗
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    // ========== 空状态 ==========
                    // 第一次打开App时引导用户添加第一条记录
                    VStack(spacing: 16) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 64))
                            .foregroundStyle(.orange.opacity(0.6))
                        
                        Text("还没有训练记录")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        Text("点击右上角 + 开始记录你的第一次训练")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                } else {
                    // ========== 训练列表 ==========
                    List {
                        ForEach(sessions) { session in
                            NavigationLink(destination: WorkoutDetailView(session: session)) {
                                WorkoutRowView(session: session)
                            }
                        }
                        .onDelete(perform: deleteSessions)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("我的训练")
            .toolbar {
                // 右上角添加按钮
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddWorkoutView()
            }
        }
    }
    
    // 滑动删除训练日
    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}

// ============================================================
// MARK: - WorkoutRowView（列表中每一行的样式）
// ============================================================
struct WorkoutRowView: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack(spacing: 12) {
            // 左侧：训练部位图标
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.orange.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Text(muscleEmoji(for: session.muscleGroup))
                    .font(.title2)
            }
            
            // 中间：训练部位 + 动作数量
            VStack(alignment: .leading, spacing: 4) {
                Text(session.muscleGroup)
                    .font(.headline)
                
                Text("\(session.exercises.count) 个动作")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 右侧：日期
            VStack(alignment: .trailing, spacing: 4) {
                Text(session.date, format: .dateTime.month(.abbreviated).day())
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(session.date, format: .dateTime.weekday(.wide))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // 根据训练部位返回对应的 Emoji（让列表更直观）
    private func muscleEmoji(for group: String) -> String {
        switch group {
        case "胸": return "🫁"
        case "背": return "🔙"
        case "腿": return "🦵"
        case "肩": return "💪"
        case "手臂": return "💪"
        case "核心": return "🎯"
        default: return "🏋️"
        }
    }
}
