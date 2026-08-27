# Imagens Originais — Jogo do Davi

Originais enviadas (upload) antes de serem recortadas/otimizadas para `app/assets/`.
Não são usadas diretamente pelo app — são a **fonte** para gerar os assets finais.

| Arquivo original | Onde virou asset | Uso atual |
|---|---|---|
| `file_00000000e354820eb45010595305fc39.png` (1536×1024) | — | — |
| `file_00000000198c820e82a90e650f7cb448.png` (1536×1024) | — | — |
| `file_00000000de2c820e81b0ea77b83121e7.png` (1672×941) | `assets/habitats/mapa_mundi.jpg` / `mapa_animais.jpg` | Mapas |
| `1787616789192.png` | — | — |
| `1787617182584.png` | — | — |
| `file_0000000035d8820e9879ae2fd63481e4.png` (1536×1024) | `assets/nomes/nomes_*.png` | Nomes (4 cenas) |
| `file_000000009cb8820ea5a8dded3acde31c.png` (1536×1024) | `assets/nomes/nomes_temas_foto.png` | Nomes > Temas |
| `file_000000007a64820e9057a288b79cdc6c.png` (1679×937) | `assets/habitats/mapa_mundi.jpg` | Mapa-múndi HD |
| `file_000000006ee8820ebe063e4bfb147152.png` (1536×1024) | `assets/alimentos/alimentos_*.png` | Alimentos (4 cenas) |
| `file_000000004db8820eb74210682d50195d.png` (1536×1024) | `assets/alimentos/alimentos_temas_foto.png` | Alimentos > Temas |
| `file_000000007ab4820eb2380c8508269598.png` (1672×941) | `assets/contas/contas_fundo.png` | **Contas** fundo |
| `file_000000003ea0820e924a07e70ac3497a.png` (1672×941) | `assets/home/home_fundo.png` | **Home** fundo |
| `file_0000000095dc820ead5ca74e8c45cd98.png` (1672×941) | `assets/colecao/colecao_fundo.png` | **Coleções** fundo (4 telas) |

> Fluxo: original → recorte PIL em `app/assets/<feature>/` → declarado em `app/pubspec.yaml` → `Image.asset` com `BoxFit.cover` + véu `0.22`.
> Não apague os originais — servem de backup para re-corte.
