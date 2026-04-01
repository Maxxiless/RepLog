// AddWorkoutView.swift
// 新建训练页面
// 用户选择日期和训练部位，创建一个新的训练日

import SwiftUI
import SwiftData

struct AddWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 表单数据
    @State private var selectedDate: Date = .now
    @State private var selectedMuscleGroup: String = "胸"
    @State private var notes: String = ""
    
    // 可选的训练部位列表（后续版本可以让用户自定义）
    private let muscleGroups = ["胸", "背", "腿", "肩", "手臂", "核心", "全身", "有氧"]
    
    var body: some View {
        NavigationStack {
            Form {
                // ========== 日期选择 ==========
                Section("训练日期") {
                    DatePicker(
                        "日期",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(.orange)
                }
                
                // ========== 训练部位选择 ==========
                Section("训练部位") {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 70))
                    ], spacing: 10) {
                        ForEach(muscleGroups, id: \.self) { group in
                            Button {
                                selectedMuscleGroup = group
                            } label: {
                                Text(group)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedMuscleGroup == group
                                            ? .orange
                                            : Color(.systemGray5)
                                    )
                                    .foregroundStyle(
                                        selectedMuscleGroup == group
                                            ? .white
                                            : .primary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // ========== 备注（可选） ==========
                Section("备注（可选）") {
                    TextField("今天状态怎么样？", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("新建训练")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 取消按钮
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                // 保存按钮
                ToolbarItem(placement: .topBarTrailing) {
                    Button("创建") {
                        saveWorkout()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                }
            }
        }
    }
    
    // 保存新的训练日到 SwiftData
    private func saveWorkout() {
        let session = WorkoutSession(
            date: selectedDate,
            muscleGroup: selectedMuscleGroup,
            notes: notes
        )
        modelContext.insert(session)
        dismiss()
    }
}
