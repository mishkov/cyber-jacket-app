import 'package:cyber_jacket/connection_provider.dart';
import 'package:cyber_jacket/database.dart';
import 'package:cyber_jacket/template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter_bloc/flutter_bloc.dart';

class TemplatesScreen extends StatefulWidget {
  static const route = '/templates';

  const TemplatesScreen({Key? key}) : super(key: key);

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder<List<Template>>(
          future: Database.instance.getAllTemplates(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final template = snapshot.data![index];

                  return Card(
                    child: ListTile(
                      title: Text(template.name),
                      onTap: () {
                        final connectionProvider =
                            context.read<BluetoothConnectionCubit>();
                        connectionProvider.sendByteFrame(template.bytes);
                      },
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 8,
                          children: List.generate(
                            64,
                            (index) {
                              final row = index % 8;
                              final column = index ~/ 8;
                              return Container(
                                margin: const EdgeInsets.all(0.5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: template.bytes[column] &
                                              (1 << (7 - row)) !=
                                          0
                                      ? Colors.red
                                      : Colors.transparent,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          Database.instance
                              .deleteTemplate(template.id)
                              .then((_) {
                            setState(() {});
                          });
                        },
                        icon: const Icon(cupertino.CupertinoIcons.trash),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
