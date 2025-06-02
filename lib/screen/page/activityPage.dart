import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sehatinapp/data/model/activity_model.dart';
import 'package:sehatinapp/screen/page/activity_data.dart';
import 'package:sehatinapp/screen/page/add_activity_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/cubit/user_cubit.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ActivityData>().loadActivities());
  }

  void _goToAddActivityPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddActivityPage(
              activities: context.read<ActivityData>().addedActivities,
            ),
      ),
    );

    if (result == true) {
      await context.read<ActivityData>().loadActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityData>(
      builder: (context, activityData, child) {
        final activities = activityData.activities;
        final addedActivities = activityData.addedActivities;
        final isLoading = activityData.isLoading;
        final progress = activityData.progress;

        final List<_ListItem> combinedList = [];

        if (activities.isNotEmpty) {
          combinedList.add(const _ListItem.header('Hari ini'));
          combinedList.addAll(activities.map((a) => _ListItem.activity(a)));
        }

        if (addedActivities.isNotEmpty) {
          combinedList.add(const _ListItem.header('Aktivitas yang dibuat'));
          combinedList.addAll(
            addedActivities.map((a) => _ListItem.activity(a)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Aktivitas",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          backgroundColor: const Color(0xFFF5F5F5),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: [
                      BlocBuilder<UserCubit, Map<String, String?>>(
                        builder: (context, userData) {
                          final photoUrl = userData['photoUrl'];
                          final name = userData['name'] ?? 'U';
                          return CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue[100],
                            backgroundImage:
                                (photoUrl != null && photoUrl.isNotEmpty)
                                    ? NetworkImage(photoUrl)
                                    : null,
                            child:
                                (photoUrl == null || photoUrl.isEmpty)
                                    ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )
                                    : null,
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Aktivitas Hari Ini",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : combinedList.isEmpty
                          ? const Center(child: Text("Belum ada aktivitas."))
                          : ListView.builder(
                            itemCount: combinedList.length,
                            itemBuilder: (context, index) {
                              final item = combinedList[index];
                              if (item.isHeader) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    item.headerText!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              } else {
                                return _buildActivityTile(
                                  item.activity!,
                                  activityData,
                                );
                              }
                            },
                          ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToAddActivityPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Tambah Aktivitas +",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityTile(Activity activity, ActivityData activityData) {
  final isUserActivity = activity.userId != null;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: activity.isDone ? Colors.grey[300] : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300, width: 1),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: GestureDetector(
        onTap: () => activityData.toggleActivityDone(activity),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2),
            color: activity.isDone ? Colors.grey : Colors.white,
          ),
          child:
              activity.isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
        ),
      ),
      title: Text(
        activity.description,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          decoration: null,
          color:
              activity.isDone
                  ? Colors.grey
                  : isUserActivity
                      ? Colors.grey[800]
                      : Colors.black,
        ),
      ),
      trailing:
          isUserActivity
              ? IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: () => _showDeleteDialog(activityData, activity),
                  splashRadius: 20,
                  tooltip: 'Hapus',
                )
              : null,
    ),
  );
}

  void _showDeleteDialog(ActivityData activityData, Activity activity) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Aktivitas'),
          content: Text('Yakin ingin menghapus "${activity.description}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                activityData.deleteAddedActivity(activity.id);
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

class _ListItem {
  final bool isHeader;
  final String? headerText;
  final Activity? activity;

  const _ListItem.header(this.headerText) : isHeader = true, activity = null;

  const _ListItem.activity(this.activity) : isHeader = false, headerText = null;
}
