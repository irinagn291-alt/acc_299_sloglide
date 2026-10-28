import Foundation

/// Pure fold over one root. Stash writes the foyer only. Light samples one
/// pass onto a Dark marquee. Dismiss files a finish, opens grade, and folds
/// Lit back to Dark. Refusals return a mark and do not mutate.
extension RepertoryRoot {
    func hushIfIdle() -> Hush? {
        guard marquee.isDark, foyer.passes.isEmpty else { return nil }
        return .idle
    }

    mutating func stash(_ pass: Pass) -> FoldMark {
        foyer.append(pass)
        return .stashed(pass)
    }

    mutating func light(passID: UUID) -> FoldMark {
        guard marquee.isDark else { return .double(.alreadyLit) }
        guard let pass = foyer.remove(id: passID) else {
            if let hush = hushIfIdle() { return .hush(hush) }
            return .empty(.dark)
        }
        marquee.phase = .lit(pass)
        return .lit(LightMark(passID: pass.id))
    }

    mutating func dismiss(on date: Date, calendar: Calendar) -> FoldMark {
        guard let pass = marquee.litPass else {
            if let hush = hushIfIdle() { return .hush(hush) }
            return .empty(.dark)
        }
        let mark = RepMark(pass: pass, daykey: DayKey.yyyymmdd(date, calendar: calendar))
        rep.append(mark)
        marquee.phase = .dark
        openGradeID = mark.id
        return .dismissed(mark)
    }

    mutating func confirmGrade(_ grade: Int) -> FoldMark? {
        guard (1...5).contains(grade), let openID = openGradeID else { return nil }
        guard let index = rep.firstIndex(where: { $0.id == openID }) else {
            openGradeID = nil
            return nil
        }
        rep[index].grade = grade
        openGradeID = nil
        return .graded(rep[index])
    }

    /// Drops the latest finish and returns that pass to the foyer head.
    /// A lit marquee stays lit.
    mutating func peel() -> FoldMark? {
        guard let mark = rep.popLast() else { return nil }
        if openGradeID == mark.id {
            openGradeID = nil
        }
        foyer.insertAtHead(mark.pass)
        return .peeled(PeelMark(restored: mark.pass))
    }

    mutating func moveQueued(_ id: UUID, before: UUID) {
        foyer.move(id, before: before)
    }

    mutating func completeOnboarding() {
        onboardingComplete = true
    }
}
