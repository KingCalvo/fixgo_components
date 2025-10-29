List<String> serviceMiniImages(String serviceType) {
  final key = serviceType.trim().toLowerCase();

  const map = {
    'pintura': ['assets/PinturaImg.png'],
    'plomeria': ['assets/PlomeriaImg.png'],
    'plomería': ['assets/PlomeriaImg.png'],
    'jardineria': ['assets/JardineriaImg.png'],
    'jardinería': ['assets/JardineriaImg.png'],
    'herrería': ['assets/HerreriaImg.png'],
    'herreria': ['assets/HerreriaImg.png'],
    'limpieza exteriores': ['assets/LimpiezaExterioresImg.png'],
    'reparacion electrodomesticos': ['assets/ReparacionElectroImg.png'],
    'reparación electrodomesticos': ['assets/ReparacionElectroImg.png'],
  };

  // Fallback por si no hay
  return map[key] ?? ['assets/LogoVerde.png'];
}
