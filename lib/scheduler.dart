// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class Scheduler extends StatefulWidget {
  const Scheduler({super.key});

  @override
  SchedulerState createState() => SchedulerState();
}

class SchedulerState extends State<Scheduler> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TimeOfDay? taskStartTime;
  TimeOfDay? taskEndTime;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Function to select both start and end times for the main scheduler
  Future<void> _selectTimeRange(BuildContext context) async {
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );

    if (pickedStartTime != null) {
      final TimeOfDay? pickedEndTime = await showTimePicker(
        context: context,
        initialTime: endTime ?? pickedStartTime,
      );

      if (pickedEndTime != null) {
        setState(() {
          startTime = pickedStartTime;
          endTime = pickedEndTime;
        });
      }
    }
  }

  // Function to select start and end times for a specific task
  Future<void> _selectTaskTimeRange(BuildContext context) async {
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: taskStartTime ?? TimeOfDay.now(),
    );

    if (pickedStartTime != null) {
      final TimeOfDay? pickedEndTime = await showTimePicker(
        context: context,
        initialTime: taskEndTime ?? pickedStartTime,
      );

      if (pickedEndTime != null) {
        setState(() {
          taskStartTime = pickedStartTime;
          taskEndTime = pickedEndTime;
        });
      }
    }
  }

  // Helper function to convert TimeOfDay to minutes
  int timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // Helper function to convert minutes to slot index
  int timeToSlotIndex(TimeOfDay time) {
    return (timeToMinutes(time) / 30).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduler'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Text Fields for task title and description
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 2, // To make the description multiline
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              // Button for selecting task-specific start and end time
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectTaskTimeRange(
                          context), // Trigger task time selection
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        taskStartTime == null || taskEndTime == null
                            ? 'Select Task Time'
                            : 'Task Time: ${taskStartTime!.format(context)} - ${taskEndTime!.format(context)}',
                      ),
                    ),
                  ],
                ),
              ),
              // Button for selecting main scheduler start and end time
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Colors.green[50], // Background color of the container
                    borderRadius: BorderRadius.circular(12), // Border radius
                    border: Border.all(
                      color: Colors.blue,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () => _selectTimeRange(
                        context), // Trigger main scheduler time selection
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      startTime == null || endTime == null
                          ? 'Select Start and End Time'
                          : 'Scheduler Times: ${startTime!.format(context)} - ${endTime!.format(context)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // Time Bar Section
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Stack(
                  children: [
                    Row(
                      children: List.generate(48, (index) {
                        final hour = index ~/ 2;
                        final minute = (index % 2) * 30;
                        final time =
                            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

                        final currentSlotMinutes = hour * 60 + minute;
                        final isWithinRange = startTime != null &&
                            endTime != null &&
                            currentSlotMinutes >= timeToMinutes(startTime!) &&
                            currentSlotMinutes <= timeToMinutes(endTime!);

                        return Container(
                          alignment: Alignment.topCenter,
                          width: 70,
                          height: 700, // Adjust height as needed
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isWithinRange ? Colors.purple : Colors.blue,
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                    ),
                    // Task Time Range - Display Task Time Range inside the blue area
                    if (taskStartTime != null && taskEndTime != null)
                      Positioned(
                        left: (timeToSlotIndex(taskStartTime!) * 70.0),
                        top: 0,
                        child: Container(
                          margin: EdgeInsets.only(top: 30.0),
                          width: (timeToSlotIndex(taskEndTime!) -
                                  timeToSlotIndex(taskStartTime!)) *
                              70.0,
                          height: 20, // Task bar height
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${taskStartTime!.format(context)} - ${taskEndTime!.format(context)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
