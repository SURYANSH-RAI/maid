import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/model.dart';
import 'package:maid/theme.dart';
import 'package:maid/lib.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void testFileExisting() async {
    if (Platform.isIOS) {
      (await SharedPreferences.getInstance()).remove('path');
    }

    if (model.modelPath != "" && await File(model.modelPath).exists()) {
      setState(() {
        model.fileState = FileState.found;
      });
    } else {
      setState(() {
        model.fileState = FileState.notFound;
      });
    }
  }

  @override
  initState() {
    super.initState();
    testFileExisting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Text(
              model.modelName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () async {
                    await model.openFile();
                    model.saveAll();
                    setState(() {});
                  },
                  child: const Text(
                    "Load Model",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                FilledButton(
                  onPressed: () {
                    model.resetAll(setState);
                  },
                  child: const Text(
                    "Reset All",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            llamaParamTextField(
              'User alias', model.userAliasController),
            llamaParamTextField(
              'Response alias', model.responseAliasController),
            ListTile(
              title: Row(
                children: [
                  const Expanded(
                    child: Text('PrePrompt'),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: model.prePromptController,
                      decoration: roundedInput('PrePrompt', context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    setState(() {
                      model.examplePromptControllers.add(TextEditingController());
                      model.exampleResponseControllers.add(TextEditingController());
                    });
                  },
                  child: const Text(
                    "Add Example",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      model.examplePromptControllers.removeLast();
                      model.exampleResponseControllers.removeLast();
                    });
                  },
                  child: const Text(
                    "Remove Example",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            ...List.generate(
              (model.examplePromptControllers.length == model.exampleResponseControllers.length) ? model.examplePromptControllers.length : 0,
              (index) => Column(
                children: [
                  llamaParamTextField('Example prompt', model.examplePromptControllers[index]),
                  llamaParamTextField('Example response', model.exampleResponseControllers[index]),
                ],
              ),
            ),
            llamaParamSwitch(
              'memory_f16', model.memory_f16, 'memory_f16'),
            llamaParamSwitch(
              'random_prompt', model.random_prompt, 'random_prompt'),
            llamaParamSwitch(
              'interactive', model.interactive, 'interactive'),
            llamaParamSwitch(
              'interactive_start', model.interactive_start, 'interactive_start'),
            llamaParamSwitch(
              'instruct (Chat4all and Alpaca)', model.instruct, 'instruct'),
            llamaParamSwitch(
              'ignore_eos', model.ignore_eos, 'ignore_eos'),
            llamaParamSwitch(
              'perplexity', model.perplexity, 'perplexity'),
            const SizedBox(height: 15.0),
            llamaParamTextField(
              'seed (-1 for random)', model.seedController),
            llamaParamTextField(
              'n_threads', model.n_threadsController),
            llamaParamTextField(
              'n_predict', model.n_predictController),
            llamaParamTextField(
              'repeat_last_n', model.repeat_last_nController),
            llamaParamTextField(
              'n_parts (-1 for auto)', model.n_partsController),
            llamaParamTextField(
              'n_ctx', model.n_ctxController),
            llamaParamTextField(
              'top_k', model.top_kController),
            llamaParamTextField(
              'top_p', model.top_pController),
            llamaParamTextField(
              'temp', model.tempController),
            llamaParamTextField(
              'repeat_penalty', model.repeat_penaltyController),
            llamaParamTextField(
              'batch_size', model.n_batchController),
          ],
        ),
      )
    );
  }

  Widget llamaParamTextField(String labelText, TextEditingController controller) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(labelText),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              decoration: roundedInput(labelText, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget llamaParamSwitch(String title, bool initialValue, String key) {
    return SwitchListTile(
      title: Text(title),
      value: initialValue,
      onChanged: (value) {
        setState(() {
          switch (key) {
            case 'memory_f16':
              model.memory_f16 = value;
              break;
            case 'random_prompt':
              model.random_prompt = value;
              break;
            case 'interactive':
              model.interactive = value;
              break;
            case 'interactive_start':
              model.interactive_start = value;
              break;
            case 'instruct':
              model.instruct = value;
              break;
            case 'ignore_eos':
              model.ignore_eos = value;
              break;
            case 'perplexity':
              model.perplexity = value;
              break;
            default:
              break;
          }
          model.saveBoolToSharedPrefs(key, value);
        });
      },
    );
  }
}
