import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 350;
    final bool isDark=Theme.of(context).brightness==Brightness.dark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your Activity",
          style: TextStyle(
            letterSpacing: 1.1,
            wordSpacing: 1.1,),),
          centerTitle: true,
          forceMaterialTransparency: true,

        ),
        body: Consumer<DatabaseHelperProvider>(
          builder: (ctx, provider, __) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final activityList =
                Provider.of<DatabaseHelperProvider>(
                  ctx,
                ).attendance;

            if (activityList == null ||
                activityList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No attendance activity available.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }

            // ListView
            return ListView.builder(
              itemCount: activityList.length,
              itemBuilder: (context, index) {
                var event = activityList[index];
                return Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: isSmallScreen ? 6 : 12,
                  ),
                  padding: EdgeInsets.all(
                    isSmallScreen ? 8 : 12,
                  ),
                  decoration: BoxDecoration(
                    color:isDark?Color(0xCC000000):Color(0xFFF1EEEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          isSmallScreen ? 6 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0x1A2196F3),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Icon(
                          event["icon"] ??
                              Icons.help_outline_sharp,
                          color: Colors.blue,
                          size: isSmallScreen ? 18 : 24,
                        ),
                      ),
                      SizedBox(
                        width: isSmallScreen ? 8 : 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              event["title"] ??
                                  "Unknown Title",
                              style: TextStyle(
                                fontSize:
                                isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,

                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                            ),
                            Text(
                              event["date"] ??
                                  "Unknown Date",
                              style: TextStyle(
                                color:isDark? Colors.white70:Colors.black87,
                                fontSize:
                                isSmallScreen ? 10 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            event["time"] ?? "--:--",
                            style: TextStyle(
                              fontSize:
                              isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                          Text(
                            event["status"] ?? "No Status",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize:
                              isSmallScreen ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
