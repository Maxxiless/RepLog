// Models.swift
// 数据模型定义
// 三层结构：训练日 → 动作 → 每组详情

import Foundation
import SwiftData

// ============================================================
// MARK: - WorkoutSession（训练日）
// 代表某一天的一次完整训练，包含日期和训练部位
// ============================================================
@Model
final class WorkoutSession {
    var date: Date                    // 训练日期
    var muscleGroup: String           // 训练部位，如"胸"、"背"、"腿"
    var notes: String                 // 备注（可选）
    
    // 一次训练包含多个动作，使用级联删除
    @Relationship(deleteRule: .cascade)
    var exercises: [ExerciseEntry] = []
    
    init(date: Date = .now, muscleGroup: String = "", notes: String = "") {
        self.date = date
        self.muscleGroup = muscleGroup
        self.notes = notes
    }
}

// ============================================================
// MARK: - ExerciseEntry（具体动作）
// 代表一个具体训练动作，比如"平板卧推"
// ============================================================
@Model
final class ExerciseEntry {
    var name: String                  // 动作名称，如"卧推"、"深蹲"
    var order: Int                    // 动作顺序（用于排序显示）
    
    // 每个动作包含多组训练数据
    @Relationship(deleteRule: .cascade)
    var sets: [ExerciseSet] = []
    
    // 反向关联到所属的训练日
    var session: WorkoutSession?
    
    init(name: String = "", order: Int = 0) {
        self.name = name
        self.order = order
    }
}

// ============================================================
// MARK: - ExerciseSet（每一组）
// 代表一组训练的具体数据：重量和次数
// ============================================================
@Model
final class ExerciseSet {
    var setNumber: Int                // 第几组
    var weight: Double                // 重量（kg）
    var reps: Int                     // 次数
    var isCompleted: Bool             // 是否完成（方便训练中打勾）
    
    // 反向关联到所属的动作
    var exercise: ExerciseEntry?
    
    init(setNumber: Int = 1, weight: Double = 0, reps: Int = 0, isCompleted: Bool = false) {
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
    }
}
