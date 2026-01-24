// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Budget _$BudgetFromJson(Map<String, dynamic> json) => _Budget(
  id: json['id'] as String,
  categoryId: json['categoryId'] as String,
  amount: (json['amount'] as num).toDouble(),
  spent: (json['spent'] as num).toDouble(),
  month: (json['month'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  note: json['note'] as String?,
);

Map<String, dynamic> _$BudgetToJson(_Budget instance) => <String, dynamic>{
  'id': instance.id,
  'categoryId': instance.categoryId,
  'amount': instance.amount,
  'spent': instance.spent,
  'month': instance.month,
  'year': instance.year,
  'note': instance.note,
};
