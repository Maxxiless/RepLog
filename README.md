# RepLog 🏋️‍♂️

**A clean, minimal fitness logging app for lifters who code.**

RepLog is an open-source iOS app built with SwiftUI and SwiftData that helps you track your workouts — sets, reps, and weights — with zero distractions.

The name says it all: **Rep** (as in repetitions in the gym) + **Log** (as in logging your data to the console). If you live in both the gym and the terminal, this one's for you.

---

## Why RepLog?

Most fitness apps are bloated with social features, AI coaches, and subscription paywalls. RepLog takes the opposite approach — it's a simple, fast, local-first workout logger that does one thing well: **recording what you lifted today.**

No account required. No cloud sync. No ads. Just you, your sets, and your data — stored on your device with Apple's SwiftData framework.

---

## Features

- **Workout Logging** — Create training sessions by date and muscle group (chest, back, legs, shoulders, arms, core, full body, cardio)
- **Exercise Tracking** — Add multiple exercises per session, each with its own sets, weight (kg), and rep count
- **Set Completion** — Tap the checkmark to mark sets as done during your workout, so you never lose track mid-session
- **Calendar Overview** — A monthly calendar view with orange dot indicators showing which days you trained
- **Monthly Stats** — At-a-glance summary of your training days, total exercises, and total sets for the current month
- **100% Local Storage** — All data persisted on-device using SwiftData. Your workout data never leaves your phone.

---

## Screenshots

<p align="center">
  <i>Screenshots coming soon — contributions welcome!</i>
</p>

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | SwiftUI |
| Data Persistence | SwiftData |
| Minimum iOS | 17.0 |
| Language | Swift 5.9+ |
| IDE | Xcode 16+ |
| Dependencies | None — zero external packages |

---

## Architecture

RepLog uses a clean three-layer data model that maps directly to how lifters think about their training:

```
WorkoutSession (训练日)
  ├── date, muscleGroup, notes
  └── exercises: [ExerciseEntry]
        ├── name, order
        └── sets: [ExerciseSet]
              ├── setNumber
              ├── weight (kg)
              ├── reps
              └── isCompleted
```

- **WorkoutSession** — A single training day. Stores the date, which muscle group you hit, and optional notes about how the session felt.
- **ExerciseEntry** — A specific movement within a session (e.g., bench press, squat, lat pulldown). Ordered so your exercises stay in the sequence you added them.
- **ExerciseSet** — One working set: how much weight, how many reps, and whether you completed it.

All relationships use cascade delete — removing a session automatically cleans up its exercises and sets.

---

## Getting Started

### Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 16.0 or later
- iOS 17.0+ Simulator or physical device

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Maxxiless/RepLog.git
   ```

2. Open `RepLog.xcodeproj` in Xcode

3. Select an iPhone simulator (e.g., iPhone 16 Pro)

4. Press `Cmd + R` to build and run

That's it. No CocoaPods, no Swift Package Manager dependencies, no environment variables. Just clone, open, and run.

---

## Roadmap

Here's what's planned for future versions:

- [ ] Dark mode optimization
- [ ] Exercise template library (pre-built lists per muscle group so you don't have to type every time)
- [ ] Weight progression charts (visualize how your bench press has grown over weeks)
- [ ] Rest timer between sets
- [ ] Export workout data (CSV / JSON)
- [ ] Apple Watch companion app
- [ ] Home screen widgets showing today's workout summary
- [ ] Localization (English / Chinese)

Have a feature idea? [Open an issue](https://github.com/Maxxiless/RepLog/issues) and let me know.

---

## Contributing

Contributions are welcome — whether it's a bug fix, a new feature, a UI improvement, or just fixing a typo in this README.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Author

**Hao Xu** ([@Maxxiless](https://github.com/Maxxiless))

PhD Researcher at Newcastle University, UK 🇬🇧

Built with SwiftUI, powered by caffeine and progressive overload.

---

<p align="center">
  If you find RepLog useful, consider giving it a ⭐ — it helps others discover the project.
</p>
