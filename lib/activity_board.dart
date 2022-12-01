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
  // stores the list of activities done on the ticket.
  List<String> activityList = [];

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // the input box to add a new activity record.
      Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: TextBox(
            controller: _controller,
            onSubmitted: (str) {
              _controller.clear;
              setState(() {
                activityList.add(str);
              });
            },
            foregroundDecoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide.none,
              ),
            ),
          )),
      // the list of activities.
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: activityList
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
      )
    ]);
  }
}
