import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

//import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'dart:core';

import 'package:search_choices/search_choices.dart';

class SearchableDropDownFieldBlocBuilder<Value> extends StatelessWidget {
  const SearchableDropDownFieldBlocBuilder({
    Key? key,
    required this.selectFieldBloc,
    required this.itemBuilder,
    required this.hint,
    required this.searchHint,
    this.height = 200,
    this.iconSize = 24.0,
  }) : super(key: key);

  final SelectFieldBloc<Value, dynamic> selectFieldBloc;
  final itemBuilder;
  final String hint;
  final String searchHint;
  final double iconSize;
  final double height;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectFieldBloc, SelectFieldBlocState>(
      bloc: selectFieldBloc,
      builder: (context, state) {
        final List<DropdownMenuItem> items = state.items
            .map((e) => DropdownMenuItem(
//                  child: Text(itemBuilder(context, e)),
                  child: Text(itemBuilder(context, e)),
                  value: e,
//                  onTap: () {
//                    print("selectFieldBloc.updateValue(e)");
//                    selectFieldBloc.updateValue(e);
//                  },
                ))
            .toList();

        return Column(
          children: [
//            Text(hint),
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              child: SearchChoices.single(
//                disabledHint: ,

                validator: (value) {
                  return state.canShowError ? "Ce champ est obligatoire" : "";
                },
                // label: Text(hint),
                items: items,
                value: state.value,
//                hint: hint,
//                searchHint: searchHint,
                selectedValueWidgetFn: (item) {
                  return (Center(
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          margin: EdgeInsets.all(1),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(item["capital"]),
                          ))));
                },
                onChanged: (value) {
                  selectFieldBloc.updateValue(value);
//            if (state.items is List<CurrencyModel>)
//                          selectFieldBloc.updateValue(
//                              state.items.firstWhere((element) => element.value == value));
//            if (state.items is List<Account>)
//                          selectFieldBloc.updateValue(
//                              state.items.firstWhere((element) => element.value == value));
                },
                isExpanded: true,
                displayClearIcon: false,
                iconSize: iconSize,
                closeButton: null,
                dialogBox: true,
                // menuConstraints: BoxConstraints.expand(height: height),
              ),
            ),
          ],
        );
      },
    );
  }
}
