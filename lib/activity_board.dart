import 'package:fastim/incidents_manager.dart';
import 'package:fluent_ui/fluent_ui.dart';
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
              setState(() {
                Provider.of<IncidentModel>(context, listen: false)
                    .activityList
                    .add(newActivity);
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
        builder: (context, incidentModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: incidentModel.activityList
                .map((activity) => Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            FluentIcons.circle_ring,
                            size: 8,
                          ),
                        ),
                        Text(activity),
                      ],
                    ))
                .toList(),
          );
        },
      )
    ]);
  }
}