# Task: Custom Activity Calendar Implementation

Implement a custom calendar UI where each day displays a circular progress ring indicating the user's activity level for that day, as shown in the provided reference image.

## 📋 Requirements

1.  **Circular Activity Indicator**:
    - Each day in the calendar should have a circular ring.
    - The ring should be an arc representing the "activity level" (e.g., 0% to 100%).
    - 100% activity = full circle.
    - Default style: Light gray background circle, black active arc.
2.  **Selected/Today Highlight**:
    - The selected day should have a solid black background with white text.
3.  **Activity Calculation**:
    - Activity should be calculated based on the user's `TimeEntry` data for that specific day.
    - Metric: Total XP earned for the day relative to a "Daily Goal" (e.g., 100 XP).
4.  **Data Fetching**:
    - Ensure the calendar fetches or receives data for the entire month to render all activity rings.

## 🛠 Plan

### Phase 1: Analysis & Infrastructure
- [x] Determine the "Daily XP Goal" constant.
- [x] Create a provider to fetch activity levels for a given month/range.
- [x] Implement a `ActivityRingPainter` custom painter for the arc.

### Phase 2: Implementation
- [x] Update `MonthViewModal` to use `calendarBuilders` in `TableCalendar`.
- [x] Implement `defaultBuilder`, `holidayBuilder`, `outsideBuilder` to include the activity ring.
- [x] Implement `selectedBuilder` and `todayBuilder` to match the design (solid circle for selected).
- [x] Connect the builders to the activity data provider.

### Phase 3: Verification
- [ ] Verify animations (if any) and visual accuracy against the image.
- [ ] Ensure performance is maintained when rendering 30+ rings.
