import 'package:flutter/material.dart';

class DependencyInfo {
  final String name;
  final String version;
  final String license;
  final String url;

  const DependencyInfo({
    required this.name,
    required this.version,
    required this.license,
    required this.url,
  });
}

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créditos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppInfo(context),
          const SizedBox(height: 24),
          _buildDeveloperSection(context),
          const SizedBox(height: 24),
          _buildToolsSection(context),
          const SizedBox(height: 24),
          _buildLicenseSection(context),
          const SizedBox(height: 24),
          _buildDependenciesSection(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/icons/logo_rcc.png',
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Radio Comunitaria de Colombia',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Hub de emisoras educativas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Versión 1.0.0 (1)',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Creado por',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jaime Hernández',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Text(
                        'usando OpenCode',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('GitHub: github.com/jalheart'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.code, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'github.com/jalheart',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Herramientas de desarrollo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.code, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: const Text(
                'OpenCode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Terminal-based AI coding assistant'),
              trailing: const Text(
                'https://opencode.ai',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Licencia',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'MIT License',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Copyright (c) 2026 Radio Comunitaria de Colombia\n\n'
              'Permission is hereby granted, free of charge, to any person obtaining a copy '
              'of this software and associated documentation files (the "Software"), to deal '
              'in the Software without restriction, including without limitation the rights '
              'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
              'copies of the Software, and to permit persons to whom the Software is '
              'furnished to do so, subject to the following conditions:\n\n'
              'The above copyright notice and this permission notice shall be included in all '
              'copies or substantial portions of the Software.\n\n'
              'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
              'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
              'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
              'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
              'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
              'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE '
              'SOFTWARE.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDependenciesSection(BuildContext context) {
    final dependencies = [
      const DependencyInfo(
        name: 'http',
        version: '^1.2.0',
        license: 'BSD-3-Clause',
        url: 'https://pub.dev/packages/http',
      ),
      const DependencyInfo(
        name: 'hive',
        version: '^2.2.3',
        license: 'Apache-2.0',
        url: 'https://pub.dev/packages/hive',
      ),
      const DependencyInfo(
        name: 'hive_flutter',
        version: '^1.1.0',
        license: 'Apache-2.0',
        url: 'https://pub.dev/packages/hive_flutter',
      ),
      const DependencyInfo(
        name: 'just_audio',
        version: '^0.9.40',
        license: 'MIT',
        url: 'https://pub.dev/packages/just_audio',
      ),
      const DependencyInfo(
        name: 'audio_service',
        version: '^0.18.18',
        license: 'MIT',
        url: 'https://pub.dev/packages/audio_service',
      ),
      const DependencyInfo(
        name: 'provider',
        version: '^6.1.0',
        license: 'MIT',
        url: 'https://pub.dev/packages/provider',
      ),
      const DependencyInfo(
        name: 'cached_network_image',
        version: '^3.4.1',
        license: 'MIT',
        url: 'https://pub.dev/packages/cached_network_image',
      ),
      const DependencyInfo(
        name: 'flutter_cache_manager',
        version: '^3.4.1',
        license: 'MIT',
        url: 'https://pub.dev/packages/flutter_cache_manager',
      ),
      const DependencyInfo(
        name: 'audio_session',
        version: '^0.1.25',
        license: 'MIT',
        url: 'https://pub.dev/packages/audio_session',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Dependencias',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Esta aplicación utiliza las siguientes librerías de terceros:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            ...dependencies.map((dep) => _buildDependencyTile(context, dep)),
          ],
        ),
      ),
    );
  }

  Widget _buildDependencyTile(BuildContext context, DependencyInfo dep) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Más info: ${dep.url}'),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dep.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'v${dep.version}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  dep.license,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
