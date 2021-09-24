import 'dart:convert';

import 'package:bytebankapi/http/webclient.dart';
import 'package:bytebankapi/models/contact.dart';
import 'package:bytebankapi/models/transaction.dart';
import 'package:http/http.dart';

class TransactionWebClient {
  //busca
  Future<List<Transaction>> findAll() async {
    //cria o client e utiliza ele para fazer o get
    //colocamos na lista de interceptadores as instâncias dos interceptadores que a gente quer adicionar

    //o get é uma requisição e precisamos da resposta dela, podemos usar o then ou o async await
    //o response recebe um json
    final Response response =
        //ao invés de fazer o get sozinho, ele é utilizado a partir do client
        await client
            .get(
              Uri.parse(baseUrl),
            )
            .timeout(
              Duration(seconds: 5),
            );

    List<Transaction> transactions = _toTransactions(response);
    return transactions;
  }

  Future<Transaction> save(Transaction transaction) async {
    Map<String, dynamic> transactionMap = _toMap(transaction);
    //encode vai deovlver uma String que vai representar o json
    final String transactionJson = jsonEncode(transactionMap);

    final Response response = await client.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-type': 'application/json',
        'password': '1000',
      },
      //convertemos o objeto em json
      body: transactionJson,
    );

    return _toTransaction(response);
  }

  //converte o json para objeto
  List<Transaction> _toTransactions(Response response) {
    final List<dynamic> decodedJson = jsonDecode(response.body);
    final List<Transaction> transactions = [];
    //passar por cada um dos elementos e criar uma transferência
    for (Map<String, dynamic> transactionJson in decodedJson) {
      final Map<String, dynamic> contactJson = transactionJson['contact'];
      final Transaction transaction = Transaction(
        transactionJson['value'],
        Contact(
          0,
          contactJson['name'],
          contactJson['accountNumber'],
        ),
      );
      transactions.add(transaction);
    }
    return transactions;
  }

//enviar transação e salvar na web API

  Transaction _toTransaction(Response response) {
    Map<String, dynamic> json = jsonDecode(response.body);

    final Map<String, dynamic> contactJson = json['contact'];
    return Transaction(
      json['value'],
      Contact(
        0,
        contactJson['name'],
        contactJson['accountNumber'],
      ),
    );
  }

  Map<String, dynamic> _toMap(Transaction transaction) {
    final Map<String, dynamic> transactionMap = {
      'value': transaction.value,
      'contact': {
        'name': transaction.contact.name,
        'accountNumber': transaction.contact.accountNumber
      }
    };
    return transactionMap;
  }
}
