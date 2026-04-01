// WorkoutDetailView.swift
// 训练详情页
// 显示某一天训练的所有动作和每组数据，支持添加动作和组数

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 当前查看的训练日（由上一页传入）
    @Bindable var session: WorkoutSession
    
    // 控制"添加动作"弹窗
    @State private var showingAddExercise = false
    @State private var newExerciseName = ""
    
    // 按 order 字段排序后的动作列表
    private var sortedExercises: [ExerciseEntry] {
        session.exercises.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        List {
            // ========== 训练概览信息 ==========
            Section {
                HStack {
                    Label("部位", systemImage: "figure.strengthtraining.traditional")
                    Spacer()
                    Text(session.muscleGroup)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label("日期", systemImage: "calendar")
                    Spacer()
                    Text(session.date, format: .dateTime.year().month().day())
                        .foregroundStyle(.secondary)
                }
                
                // 如果有备注则显示
                if !session.notes.isEmpty {
                    HStack(alignment: .top) {
                        Label("备注", systemImage: "note.text")
                        Spacer()
                        Text(session.notes)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            
            // ========== 每个动作的详情 ==========
            ForEach(sortedExercises) { exercise in
                Section {
                    // 动作标题行
                    HStack {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        Spacer()
                        
                        Text("\(exercise.sets.count) 组")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    
                    // 表头
                    HStack {
                        Text("组数")
                            .frame(width: 40, alignment: .leading)
                        Text("重量(kg)")
                            .frame(maxWidth: .infinity)
                        Text("次数")
                            .frame(maxWidth: .infinity)
                        Text("✓")
                            .frame(width: 30)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    // 每一组的数据
                    ForEach(sortedSets(for: exercise)) { set in
                        ExerciseSetRow(set: set)
                    }
                    .onDelete { offsets in
                        deleteSets(exercise: exercise, at: offsets)
                    }
                    
                    // 添加一组的按钮
                    Button {
                        addSet(to: exercise)
                    } label: {
                        Label("添加一组", systemImage: "plus.circle")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .onDelete(perform: deleteExercises)
            
            // ========== 添加新动作按钮 ==========
            Section {
                Button {
                    showingAddExercise = true
                } label: {
                    Label("添加动作", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(session.muscleGroup + " 训练")
        .navigationBarTitleDisplayMode(.inline)
        // 添加动作的弹窗
        .alert("添加动作", isPresented: $showingAddExercise) {
            TextField("动作名称（如：卧推）", text: $newExerciseName)
            Button("取消", role: .cancel) {
                newExerciseName = ""
            }
            Button("添加") {
                addExercise()
            }
        } message: {
            Text("输入你要做的动作名称")
        }
    }
    
    // 对某个动作的组数按 setNumber 排序
    private func sortedSets(for exercise: ExerciseEntry) -> [ExerciseSet] {
        exercise.sets.sorted { $0.setNumber < $1.setNumber }
    }
    
    // 添加新动作
    private func addExercise() {
        guard !newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let exercise = ExerciseEntry(
            name: newExerciseName.trimmingCharacters(in: .whitespaces),
            order: session.exercises.count
        )
        exercise.session = session
        session.exercises.append(exercise)
        
        // 默认添加第一组，方便用户直接开始填数据
        let firstSet = ExerciseSet(setNumber: 1)
        firstSet.exercise = exercise
        exercise.sets.append(firstSet)
        
        newExerciseName = ""
    }
    
    // 给某个动作添加一组
    private func addSet(to exercise: ExerciseEntry) {
        let nextNumber = (exercise.sets.map(\.setNumber).max() ?? 0) + 1
        let newSet = ExerciseSet(setNumber: nextNumber)
        newSet.exercise = exercise
        exercise.sets.append(newSet)
    }
    
    // 删除动作
    private func deleteExercises(at offsets: IndexSet) {
        let sorted = sortedExercises
        for index in offsets {
            let exercise = sorted[index]
            modelContext.delete(exercise)
        }
    }
    
    // 删除某个动作中的某一组
    private func deleteSets(exercise: ExerciseEntry, at offsets: IndexSet) {
        let sorted = sortedSets(for: exercise)
        for index in offsets {
            let set = sorted[index]
            modelContext.delete(set)
        }
    }
}

// ============================================================
// MARK: - ExerciseSetRow（每一组的输入行）
// 用户可以直接在这里输入重量和次数
// ============================================================
struct ExerciseSetRow: View {
    @Bindable var set: ExerciseSet
    
    var body: some View {
        HStack {
            // 组数编号
            Text("\(set.setNumber)")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .leading)
            
            // 重量输入框
            TextField("0", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
            
            // 次数输入框
            TextField("0", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
            
            // 完成打勾按钮（训练中用来标记已完成的组）
            Button {
                set.isCompleted.toggle()
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(set.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .frame(width: 30)
        }
    }
}
