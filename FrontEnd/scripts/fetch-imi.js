const axios = require('axios');
const fs = require('fs');
const path = require('path');

const MUNICIPIOS = ['19ANGRA+DO+HEROISMO',
    '01AVEIRO',
    '02BEJA',
    '03BRAGA',
    '04BRAGANCA',
    '05C+BRANCO',
    '06COIMBRA',
    '07EVORA',
    '09GUARDA',
    '10LEIRIA',
    '11LISBOA',
    '21PONTA+DELGADA',
    '12PORTALEGRE',
    '13PORTO',
    '14SANTAREM',
    '15SETUBAL',
    '16VIANA+DO+CASTELO',
    '17VILA+REAL',
    '18VISEU',
    '19ANGRA+DO+HEROISMO',
    '20HORTA',];

const NORMALIZED = MUNICIPIOS.map(d => d.replace(/\+/g, ' '));

async function main() {
    const year = process.argv[2] || new Date().getFullYear();
    const allRecords = [];
    const BASE = 'http://192.168.23.1:3001';

    for (const distrito of NORMALIZED) {
        console.log(`Fetching ${distrito}…`);
        try {
            const res = await axios.get(`${BASE}/imi/rates`, {
                params: { ano: Number(year), distrito }
            });
            allRecords.push(...res.data);
            console.log(`  → ${res.data.length} records`);
        } catch (e) {
            console.error(
                `  ✕ error fetching ${distrito}:`,
                e.response?.statusText || e.message
            );
        }
    }

    const assetsDir = path.resolve(__dirname, '../assets/JSON');
    if (!fs.existsSync(assetsDir)) fs.mkdirSync(assetsDir);

    const outPath = path.join(assetsDir, `imi_${year}.json`);
    fs.writeFileSync(outPath, JSON.stringify(allRecords, null, 2), 'utf8');
    console.log(`\n✅ Wrote ${allRecords.length} records to ${outPath}`);
}

main();
