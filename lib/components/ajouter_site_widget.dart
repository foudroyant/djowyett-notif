import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'ajouter_site_model.dart';
export 'ajouter_site_model.dart';

class AjouterSiteWidget extends StatefulWidget {
  const AjouterSiteWidget({super.key});

  @override
  _AjouterSiteWidgetState createState() => _AjouterSiteWidgetState();
}

class _AjouterSiteWidgetState extends State<AjouterSiteWidget> {
  late AjouterSiteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AjouterSiteModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          TextFormField(
            controller: _model.textController,
            focusNode: _model.textFieldFocusNode,
            obscureText: false,
            decoration: InputDecoration(
              labelText: 'Ajouter un site',
              hintText: 'Ajouter un site',
              hintStyle: FlutterFlowTheme.of(context).bodyLarge,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0x00000000),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0x00000000),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0x00000000),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 24.0),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium,
            validator: _model.textControllerValidator.asValidator(context),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
            child: FFButtonWidget(
              onPressed: () async {
                await SitesRecord.collection.doc().set(createSitesRecordData(
                      name: _model.textController.text,
                    ));
              },
              text: 'Enregistrer',
              options: FFButtonOptions(
                width: double.infinity,
                height: 55.0,
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white,
                    ),
                elevation: 2.0,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
