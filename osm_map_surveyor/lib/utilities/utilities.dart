import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:toast/toast.dart';

double toDouble(TimeOfDay time) => time.hour + time.minute / 60.0;

void showToastMessage(BuildContext context, String message) {
  Toast.show(
    message,
    context,
    duration: Config.toastLong,
    gravity: Toast.BOTTOM,
    backgroundColor: Colors.grey[400],
    backgroundRadius: MediaQuery.of(context).size.width * 0.01,
  );
}

Widget loadingWidget(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.2,
    child: Center(
      child: CircularProgressIndicator(
        backgroundColor: Config.thirdColor,
        valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
      ),
    ),
  );
}

void showToast(BuildContext context, String message,bool isSuccess) {
  Toast.show(
    message,
    context,
    duration: Config.toastLong,
    gravity: Toast.BOTTOM,
    backgroundColor: isSuccess ? Colors.greenAccent : Colors.redAccent,
    backgroundRadius: MediaQuery.of(context).size.width * 0.01,
  );
}

class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip(this.reportList, {this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = List();

  _buildChoiceList() {
    List<Widget> choices = List();

    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}

class SingleSelectChip extends StatefulWidget {
  final List<String> reportList;
  final Function(String) onSelectionChanged;

  SingleSelectChip(this.reportList, {this.onSelectionChanged});

  @override
  _SingleSelectChipState createState() => _SingleSelectChipState();
}

class _SingleSelectChipState extends State<SingleSelectChip> {
  String selectedChoices = '';

  _buildChoiceList() {
    List<Widget> choices = List();

    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices = item;
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}