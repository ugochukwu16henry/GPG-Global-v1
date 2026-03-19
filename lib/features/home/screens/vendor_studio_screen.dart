import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/providers/backend_live_providers.dart';
import '../../storage/services/storage_service.dart';
import '../../storage/widgets/file_upload_button.dart';

class VendorStudioScreen extends ConsumerStatefulWidget {
  const VendorStudioScreen({super.key});

  @override
  ConsumerState<VendorStudioScreen> createState() => _VendorStudioScreenState();
}

class _VendorStudioScreenState extends ConsumerState<VendorStudioScreen> {
  final _categoryController = TextEditingController();
  final _reelController = TextEditingController();
  final _galleryController = TextEditingController();
  final _serviceController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _boostMediaController = TextEditingController();
  final _boostHeadlineController = TextEditingController();
  final _targetCountryController = TextEditingController();
  final _targetStatesController = TextEditingController();
  final _targetCountriesController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _pricingMode = 'FIXED';
  String _reachLevel = 'CURRENT_STATE';
  bool _isLoading = false;
  String? _error;
  String? _infoMessage;
  Map<String, dynamic>? _studio;
  List<Map<String, dynamic>> _ads = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _reelController.dispose();
    _galleryController.dispose();
    _serviceController.dispose();
    _amountController.dispose();
    _boostMediaController.dispose();
    _boostHeadlineController.dispose();
    _targetCountryController.dispose();
    _targetStatesController.dispose();
    _targetCountriesController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _infoMessage = null;
    });
    try {
      final gateway = ref.read(backendGatewayProvider);
      final userId = ref.read(backendUserIdProvider);
      final studio = await gateway.vendorStudio(userId);
      final ads = await gateway.myPromotedAds(userId: userId, limit: 30);
      if (!mounted) return;
      setState(() {
        _studio = studio;
        _ads = ads;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  List<String> _csvToList(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _saveStudio() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _infoMessage = null;
    });
    try {
      final gateway = ref.read(backendGatewayProvider);
      final userId = ref.read(backendUserIdProvider);
      await gateway.upsertVendorStudio(
        userId: userId,
        category: _categoryController.text.trim(),
        profileReelUrl: _reelController.text.trim().isEmpty
            ? null
            : _reelController.text.trim(),
        galleryUrls: _csvToList(_galleryController.text),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _addPricing() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    setState(() {
      _isLoading = true;
      _error = null;
      _infoMessage = null;
    });
    try {
      final gateway = ref.read(backendGatewayProvider);
      final userId = ref.read(backendUserIdProvider);
      await gateway.upsertVendorServicePricing(
        userId: userId,
        serviceName: _serviceController.text.trim(),
        pricingMode: _pricingMode,
        amountUsd: amount,
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _createBoost() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _infoMessage = null;
    });
    try {
      final gateway = ref.read(backendGatewayProvider);
      final userId = ref.read(backendUserIdProvider);
      await gateway.createPromotedAd(
        userId: userId,
        mediaUrl: _boostMediaController.text.trim(),
        headline: _boostHeadlineController.text.trim().isEmpty
            ? null
            : _boostHeadlineController.text.trim(),
        reachLevel: _reachLevel,
        targetCountry: _targetCountryController.text.trim().isEmpty
            ? null
            : _targetCountryController.text.trim(),
        targetStates: _csvToList(_targetStatesController.text),
        targetCountries: _csvToList(_targetCountriesController.text),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storageService = ref.watch(storageServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Studio'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_infoMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_infoMessage!,
                  style: const TextStyle(color: Colors.green)),
            ),
          if (_isLoading) const LinearProgressIndicator(),
          const SizedBox(height: 12),
          Text(_studio == null
              ? 'Vendor Studio is only available after admin approval.'
              : 'Verified Vendor: ${_studio!['vendorName']}'),
          const SizedBox(height: 14),
          const Text('Studio Setup',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (storageService != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FileUploadButton(
                  storageService: storageService,
                  bucket: StorageBucket.media,
                  label: 'Upload Profile Reel',
                  icon: Icons.video_library_outlined,
                  allowedExtensions: const ['mp4', 'mov', 'm4v', 'webm'],
                  onUploaded: (result) {
                    setState(() {
                      _reelController.text = result.path;
                      _infoMessage = 'Profile reel uploaded to storage.';
                    });
                  },
                ),
                FileUploadButton(
                  storageService: storageService,
                  bucket: StorageBucket.media,
                  label: 'Upload Gallery Image',
                  icon: Icons.photo_library_outlined,
                  allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
                  onUploaded: (result) {
                    setState(() {
                      _galleryController.text = _galleryController.text
                              .trim()
                              .isEmpty
                          ? result.path
                          : '${_galleryController.text.trim()}, ${result.path}';
                      _infoMessage = 'Gallery image uploaded to storage.';
                    });
                  },
                ),
              ],
            ),
          if (storageService != null) const SizedBox(height: 8),
          TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                  labelText: 'Category (e.g. Electrician)')),
          TextField(
              controller: _reelController,
              decoration:
                  const InputDecoration(labelText: 'Profile Reel Path / URL')),
          TextField(
              controller: _galleryController,
              decoration: const InputDecoration(
                  labelText: 'Gallery Paths / URLs (comma separated)')),
          const SizedBox(height: 8),
          FilledButton(
              onPressed: _isLoading ? null : _saveStudio,
              child: const Text('Save Studio')),
          const SizedBox(height: 16),
          const Text('Service Pricing',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
              controller: _serviceController,
              decoration: const InputDecoration(labelText: 'Service Name')),
          DropdownButtonFormField<String>(
            value: _pricingMode,
            items: const [
              DropdownMenuItem(value: 'FIXED', child: Text('Fixed Price')),
              DropdownMenuItem(
                  value: 'STARTING_FROM', child: Text('Starting From')),
            ],
            onChanged: (value) =>
                setState(() => _pricingMode = value ?? 'FIXED'),
          ),
          TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (USD)')),
          const SizedBox(height: 8),
          FilledButton(
              onPressed: _isLoading ? null : _addPricing,
              child: const Text('Add Pricing')),
          const SizedBox(height: 16),
          const Text('Boost My Talent',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (storageService != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FileUploadButton(
                storageService: storageService,
                bucket: StorageBucket.media,
                label: 'Upload Boost Media',
                icon: Icons.campaign_outlined,
                allowedExtensions: const [
                  'jpg',
                  'jpeg',
                  'png',
                  'webp',
                  'mp4',
                  'mov',
                  'm4v',
                  'webm'
                ],
                onUploaded: (result) {
                  setState(() {
                    _boostMediaController.text = result.path;
                    _infoMessage = 'Boost media uploaded to storage.';
                  });
                },
              ),
            ),
          TextField(
              controller: _boostMediaController,
              decoration:
                  const InputDecoration(labelText: 'Boost Media Path / URL')),
          TextField(
              controller: _boostHeadlineController,
              decoration: const InputDecoration(labelText: 'Headline')),
          DropdownButtonFormField<String>(
            value: _reachLevel,
            items: const [
              DropdownMenuItem(
                  value: 'CURRENT_STATE',
                  child: Text('Level 1: Current State (Free)')),
              DropdownMenuItem(
                  value: 'SELECTED_STATES',
                  child: Text('Level 2: Selected States (Paid)')),
              DropdownMenuItem(
                  value: 'GLOBAL_COUNTRIES',
                  child: Text('Level 3: Global Countries (Paid)')),
            ],
            onChanged: (value) =>
                setState(() => _reachLevel = value ?? 'CURRENT_STATE'),
          ),
          TextField(
              controller: _targetCountryController,
              decoration: const InputDecoration(labelText: 'Target Country')),
          TextField(
              controller: _targetStatesController,
              decoration: const InputDecoration(
                  labelText: 'Target States (comma separated)')),
          TextField(
              controller: _targetCountriesController,
              decoration: const InputDecoration(
                  labelText: 'Target Countries (comma separated)')),
          TextField(
              controller: _startDateController,
              decoration: const InputDecoration(
                  labelText: 'Start Date ISO (e.g. 2026-03-20T00:00:00Z)')),
          TextField(
              controller: _endDateController,
              decoration: const InputDecoration(
                  labelText: 'End Date ISO (e.g. 2026-03-30T00:00:00Z)')),
          const SizedBox(height: 8),
          FilledButton(
              onPressed: _isLoading ? null : _createBoost,
              child: const Text('Create Boost Ad')),
          const SizedBox(height: 16),
          const Text('My Active/Recent Boost Ads',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ..._ads.map((ad) => Card(
                child: ListTile(
                  title: Text((ad['headline'] ?? ad['mediaUrl']).toString()),
                  subtitle: Text(
                      '${ad['reachLevel']} · ${ad['startDate']} -> ${ad['endDate']}'),
                ),
              )),
        ],
      ),
    );
  }
}
