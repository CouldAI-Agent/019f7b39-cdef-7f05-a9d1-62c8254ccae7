import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const InvestmentTrackerApp());
}

class InvestmentTrackerApp extends StatelessWidget {
  const InvestmentTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Investment Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B3B6F), // Navy
          primary: const Color(0xFF1B3B6F), // Navy
          secondary: const Color(0xFF28A745), // Green
          surface: Colors.white,
          onSurface: Colors.black87,
          background: const Color(0xFFF8F9FA),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B3B6F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add transaction feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: isWide ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PortfolioSummaryCard(),
        SizedBox(height: 16),
        AssetAllocationCard(),
        SizedBox(height: 16),
        HoldingsListCard(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PortfolioSummaryCard(),
              SizedBox(height: 16),
              HoldingsListCard(),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: AssetAllocationCard(),
        ),
      ],
    );
  }
}

class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Portfolio Value',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$124,500.00',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.arrow_upward,
                  color: Color(0xFF28A745),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '\$4,500.00 (3.75%) All Time',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF28A745),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AssetAllocationCard extends StatelessWidget {
  const AssetAllocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Allocation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      color: const Color(0xFF1B3B6F), // Navy
                      value: 60,
                      title: '60%',
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: const Color(0xFF28A745), // Green
                      value: 25,
                      title: '25%',
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.black87,
                      value: 15,
                      title: '15%',
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Color(0xFF1B3B6F), label: 'Stocks'),
                SizedBox(width: 16),
                _LegendItem(color: Color(0xFF28A745), label: 'Bonds'),
                SizedBox(width: 16),
                _LegendItem(color: Colors.black87, label: 'Cash'),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class HoldingsListCard extends StatelessWidget {
  const HoldingsListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> holdings = [
      {'symbol': 'AAPL', 'name': 'Apple Inc.', 'shares': 50, 'price': 150.0, 'value': 7500.0, 'change': 1.2},
      {'symbol': 'MSFT', 'name': 'Microsoft Corp.', 'shares': 30, 'price': 280.0, 'value': 8400.0, 'change': 0.8},
      {'symbol': 'GOOGL', 'name': 'Alphabet Inc.', 'shares': 10, 'price': 2700.0, 'value': 27000.0, 'change': -0.5},
      {'symbol': 'AMZN', 'name': 'Amazon.com', 'shares': 20, 'price': 3300.0, 'value': 66000.0, 'change': 2.1},
      {'symbol': 'VTI', 'name': 'Vanguard Total Stock', 'shares': 70, 'price': 220.0, 'value': 15400.0, 'change': 0.3},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Holdings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: holdings.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final holding = holdings[index];
                final change = holding['change'] as double;
                final isPositive = change >= 0;
                
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      holding['symbol'][0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    holding['symbol'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(holding['name']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${holding['value'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 14,
                            color: isPositive ? const Color(0xFF28A745) : Colors.red,
                          ),
                          Text(
                            '${change.abs()}%',
                            style: TextStyle(
                              color: isPositive ? const Color(0xFF28A745) : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
