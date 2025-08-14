#
# Software Name : towards5gs-helm
# SPDX-FileCopyrightText: Copyright (c) 2021 Orange
# SPDX-License-Identifier: Apache-2.0
#
# This software is distributed under the Apache License 2.0,
# the text of which is available at https://github.com/Orange-OpenSource/towards5gs-helm/blob/main/LICENSE
# or see the "LICENSE" file for more details.
#
# Author: Abderaouf KHICHANE, Ilhem FAJJARI, Ayoub BOUSSELMI
# Software description: An open-source project providing Helm charts to deploy 5G components (Core + RAN) on top of Kubernetes
#
{{/*
Return the name of the chart
*/}}
{{- define "free5gc-amf.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Return the fully qualified app name.
If fullnameOverride is set, this is used directly.
Otherwise it uses the release name and chart name.
*/}}
{{- define "free5gc-amf.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "free5gc-amf.labels" -}}
helm.sh/chart: {{ include "free5gc-amf.chart" . }}
app.kubernetes.io/name: {{ include "free5gc-amf.name" . }}
app.kubernetes.io/instance: {{ include "free5gc-amf.fullname" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — now tied to fullnameOverride to ensure Services match Pods
*/}}
{{- define "free5gc-amf.selectorLabels" -}}
app.kubernetes.io/instance: {{ include "free5gc-amf.fullname" . }}
nf: {{ .Values.amf.name | default "amf" }}
project: {{ .Values.global.projectName | default "free5gc" }}
{{- end }}

{{/*
Chart label
*/}}
{{- define "free5gc-amf.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}
