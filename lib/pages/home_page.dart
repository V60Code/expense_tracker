import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_transaction_page.dart';

class HomePage extends StatefulWidget {
  final Function(Map<String, dynamic>) onTransactionAdded;
  final List<Map<String, dynamic>> transactions;

  const HomePage({
    super.key,
    required this.onTransactionAdded,
    required this.transactions,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  final TextEditingController _searchController = TextEditingController();
  final formatter =
      NumberFormat.currency(locale: 'id', symbol: 'IDR ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_filterTransactions);
  }

  void _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedTransactions = prefs.getString('transactions');
    if (storedTransactions != null) {
      setState(() {
        _transactions =
            List<Map<String, dynamic>>.from(json.decode(storedTransactions));
        _filteredTransactions = List.from(
            _transactions.reversed); // Menampilkan transaksi terbaru di atas
      });
    }
  }

  void _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedTransactions = json.encode(_transactions);
    await prefs.setString('transactions', encodedTransactions);
  }

  void _addTransaction(Map<String, dynamic> transaction) {
    setState(() {
      _transactions.add(transaction);
      _filteredTransactions = List.from(_transactions.reversed);
    });
    _saveTransactions();
    widget.onTransactionAdded(transaction);
  }

  void _filterTransactions() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _filteredTransactions = List.from(_transactions.reversed);
      } else {
        _filteredTransactions = _transactions
            .where((transaction) =>
                transaction['title'].toLowerCase().contains(query))
            .toList()
            .reversed
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Here's your financial summary.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard('Income', _calculateIncome(), Colors.green),
                _buildSummaryCard('Expense', _calculateExpense(), Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            _buildBalanceCard(_calculateBalance()),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Transactions',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? const Center(
                      child: Text(
                        'No transactions found!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _filteredTransactions[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTransaction = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionPage(
                addTransactionCallback: _addTransaction,
              ),
            ),
          );

          if (newTransaction != null) {
            _addTransaction(newTransaction);
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 16, color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(amount),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(balance),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          transaction['type'] == 'Income'
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          color: transaction['type'] == 'Income' ? Colors.green : Colors.red,
        ),
        title: Text(
          transaction['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(transaction['date']),
        trailing: Text(
          formatter.format(transaction['amount']),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction['type'] == 'Income' ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  double _calculateIncome() {
    return _transactions
        .where((transaction) => transaction['type'] == 'Income')
        .fold(0.0, (sum, item) => sum + item['amount']);
  }

  double _calculateExpense() {
    return _transactions
        .where((transaction) => transaction['type'] == 'Expense')
        .fold(0.0, (sum, item) => sum + item['amount']);
  }

  double _calculateBalance() {
    return _calculateIncome() - _calculateExpense();
  }
}
