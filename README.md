# Flutter Task Tracker

## SLA Rule

Tasks are classified from their completion state and calendar deadline:

- **Completed:** the task is marked complete, regardless of its deadline.
- **Overdue:** the task is incomplete and its deadline has passed.
- **At Risk:** the task is incomplete and due today or within the next two calendar days.
- **On Track:** the task is incomplete and more than two days remain.

The dashboard derives its counts and completion progress from these classifications.