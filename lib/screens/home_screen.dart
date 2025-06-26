import 'package:flutter/material.dart';
import 'dart:ui';
import '../screens/produk/produk_screen.dart';
import '../screens/layanan/layanan_screen.dart';
import '../screens/pesanan/pesanan_screen.dart';
import '../screens/transaksi/transaksi_screen.dart';
import '../screens/keuangan/keuangan_screen.dart';
import '../screens/user/profile_settings_screen.dart';
import '../screens/user/profil_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? userData;
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [];
  final List<String> _titles = [
    'Dashboard',
    'Transaksi',
    'Pesanan',
    'Produk & Layanan',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        userData = args;
      });
      
      _screens.clear();
      _screens.addAll([
        _buildDashboardScreen(),
        TransaksiScreen(userId: userData?['id']),
        const PesananScreen(),
        _buildProductServiceScreen(),
      ]);
    }
  }

  Widget _buildDashboardScreen() {
    return _DashboardScreen(
      userData: userData,
      onNavigateToScreen: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  Widget _buildProductServiceScreen() {
    return _ProductServiceScreen(
      onNavigateToProduk: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProdukScreen(),
          ),
        );
      },
      onNavigateToLayanan: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LayananScreen(),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: colorScheme.surface.withOpacity(0.7),
            ),
          ),
        ),
        title: const Text(
          'Fotokopi App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () async {
              if (userData != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilScreen(userData: userData!),
                  ),
                );
                if (result == true) {
                  setState(() {});
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black54,
                builder: (context) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Konfirmasi'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withOpacity(0.3),
                  colorScheme.surface,
                ],
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Add padding for AppBar
              const SliverPadding(
                padding: EdgeInsets.only(top: kToolbarHeight + 48),
              ),
              
              // Welcome section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                sliver: SliverToBoxAdapter(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Hero(
                                  tag: 'profile_avatar',
                                  child: CircleAvatar(
                                    backgroundColor: colorScheme.primary,
                                    radius: 30,
                                    child: Text(
                                      userData?['nama']?.substring(0, 1).toUpperCase() ?? 'U',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selamat Datang,',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userData?['nama'] ?? 'Pengguna',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Menu Utama title
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Menu Utama',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Grid menu
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildAnimatedMenuCard(
                      context,
                      'Produk',
                      Icons.inventory_2_outlined,
                      colorScheme.primary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProdukScreen(),
                        ),
                      ),
                    ),
                    _buildAnimatedMenuCard(
                      context,
                      'Layanan',
                      Icons.print_outlined,
                      colorScheme.secondary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LayananScreen(),
                        ),
                      ),
                    ),
                    _buildAnimatedMenuCard(
                      context,
                      'Pesanan',
                      Icons.assignment_outlined,
                      colorScheme.tertiary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PesananScreen(),
                        ),
                      ),
                    ),
                    _buildAnimatedMenuCard(
                      context,
                      'Transaksi',
                      Icons.receipt_long_outlined,
                      colorScheme.error,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransaksiScreen(userId: userData?['id']),
                        ),
                      ),
                    ),
                    _buildAnimatedMenuCard(
                      context,
                      'Keuangan',
                      Icons.account_balance_wallet_outlined,
                      Colors.green,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KeuanganScreen(),
                        ),
                      ),
                    ),
                    _buildAnimatedMenuCard(
                      context,
                      'Pengaturan',
                      Icons.settings_outlined,
                      Colors.grey.shade700,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileSettingsScreen(userData: userData!),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              
              // Bottom padding
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Hero(
      tag: 'menu_$title',
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _fadeAnimation.value,
              child: child,
            );
          },
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                  ),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap();
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              icon,
                              size: 32,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Function(int) onNavigateToScreen;

  const _DashboardScreen({
    required this.userData,
    required this.onNavigateToScreen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        radius: 24,
                        child: Text(
                          userData?['nama']?.substring(0, 1).toUpperCase() ?? 'U',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang,',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              userData?['nama'] ?? 'Pengguna',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          Text(
            'Aksi Cepat',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.add_shopping_cart,
                  title: 'Transaksi Baru',
                  color: colorScheme.primary,
                  onTap: () => onNavigateToScreen(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.assignment_add,
                  title: 'Pesanan Baru',
                  color: Colors.orange,
                  onTap: () => onNavigateToScreen(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Tambah Produk',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProdukScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.print_outlined,
                  title: 'Tambah Layanan',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LayananScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Financial Summary
          Text(
            'Ringkasan Keuangan',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _FinancialSummaryItem(
                    title: 'Pemasukan Hari Ini',
                    amount: 'Rp 250.000',
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                  ),
                  const Divider(),
                  _FinancialSummaryItem(
                    title: 'Pengeluaran Hari Ini',
                    amount: 'Rp 50.000',
                    icon: Icons.arrow_downward,
                    color: Colors.red,
                  ),
                  const Divider(),
                  _FinancialSummaryItem(
                    title: 'Saldo',
                    amount: 'Rp 200.000',
                    icon: Icons.account_balance_wallet,
                    color: colorScheme.primary,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Orders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan Terbaru',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => onNavigateToScreen(2),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.description_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  title: Text('Pesanan #${1001 + index}'),
                  subtitle: Text('Fotokopi ${10 * (index + 1)} lembar'),
                  trailing: Chip(
                    label: Text(
                      index == 0 ? 'Menunggu' : (index == 1 ? 'Diproses' : 'Selesai'),
                      style: TextStyle(
                        color: index == 0
                            ? Colors.orange.shade800
                            : (index == 1 ? Colors.blue.shade800 : Colors.green.shade800),
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: index == 0
                        ? Colors.orange.shade100
                        : (index == 1 ? Colors.blue.shade100 : Colors.green.shade100),
                    padding: EdgeInsets.zero,
                  ),
                  onTap: () => onNavigateToScreen(2),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinancialSummaryItem extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final bool isBold;

  const _FinancialSummaryItem({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: isBold
                  ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  : textTheme.bodyLarge,
            ),
          ),
          Text(
            amount,
            style: isBold
                ? textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  )
                : textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductServiceScreen extends StatelessWidget {
  final VoidCallback onNavigateToProduk;
  final VoidCallback onNavigateToLayanan;

  const _ProductServiceScreen({
    required this.onNavigateToProduk,
    required this.onNavigateToLayanan,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola Produk & Layanan',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih kategori yang ingin Anda kelola',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          
          // Produk Card
          _CategoryCard(
            title: 'Produk',
            description: 'Kelola stok dan harga produk yang Anda jual',
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
            onTap: onNavigateToProduk,
          ),
          
          const SizedBox(height: 16),
          
          // Layanan Card
          _CategoryCard(
            title: 'Layanan',
            description: 'Kelola jenis dan harga layanan yang Anda tawarkan',
            icon: Icons.print_outlined,
            color: Colors.green,
            onTap: onNavigateToLayanan,
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
