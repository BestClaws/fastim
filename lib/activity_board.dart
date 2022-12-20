/// the activity board records the activities done on ticket
/// trhough out its history.

import 'package:fastim/incidents_manager.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityBoard extends StatefulWidget {
  const ActivityBoard({
    Key? key,
  }) : super(key: key);

  @override
  State<ActivityBoard> createState() => _ActivityBoardState();
}

class _ActivityBoardState extends State<ActivityBoard> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // the input box to add a new activity record.
      Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: TextBox(
            placeholder: "any progress to record?",
            placeholderStyle: TextStyle(color: Colors.grey[120]),
            controller: _controller,
            onSubmitted: (newActivity) {
              _controller.clear();

              final now = DateTime.now();
              final DateFormat formatter = DateFormat('H:m MMM dd |');
              final String formattedDate = formatter.format(now);

              setState(() {
                Provider.of<IncidentModel>(context, listen: false)
                    .activityList
                    .add("$formattedDate $newActivity");
              });
            },
            foregroundDecoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide.none,
              ),
            ),
          )),
      // the list of activities.
      Consumer<IncidentModel>(
        builder: (context, incident, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: incident.activityList.reversed
                .map((activity) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            FluentIcons.circle_fill,
                            size: 8,
                          ),
                        ),
                        Expanded(child: Text(activity)),
                      ],
                    ))
                .toList(),
          );
        },
      )
    ]);
  }
}
