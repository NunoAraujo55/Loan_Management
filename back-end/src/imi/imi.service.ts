import { Injectable } from '@nestjs/common';
import axios from 'axios';
import * as cheerio from 'cheerio';
import { InjectModel } from '@nestjs/sequelize';
import { Imi } from './imi.model';
import { InferCreationAttributes } from 'sequelize';
import * as iconv from 'iconv-lite';

@Injectable()
export class ImiService {
    constructor(@InjectModel(Imi) private imiModel: typeof Imi) { }

    async scrapeAndStoreImiData(ano: number, distrito: string) {

        //const cleaned = distrito.replace(/\+/g, ' ');
        //const encodedDistrito = encodeURIComponent(cleaned).replace(/%20/g, '+');
        //if you want to use the code above use encodedDistrito instead of distrito in the const url
        const url = `https://www.portaldasfinancas.gov.pt/pt/main.jsp?body=/imi/consultarTaxasIMI.jsp&ano=${ano}&distrito=${encodeURIComponent(distrito)}`;
        console.log(url);
        const resp = await axios.get(url, { responseType: 'arraybuffer' });
        const html = iconv.decode(resp.data, 'latin1');
        const $ = cheerio.load(html);

        const results: InferCreationAttributes<Imi>[] = [];

        $('table.iT tbody tr').each((index, element) => {
            const $tds = $(element).find('td');
            const municipio = $tds.eq(1).text().trim();
            const taxaRaw = $tds.eq(2).text().trim();
            const taxa = parseFloat(
                taxaRaw
                    .replace(/\s|%/g, '')
                    .replace(',', '.')
            );

            if (municipio && !isNaN(taxa)) {
                results.push({ distrito, municipio, taxa, ano });
            }
        });

        await this.imiModel.bulkCreate(results, { ignoreDuplicates: true });

        return results;
    }


    async getStoredImiData(ano: number, distrito: string): Promise<Imi[]> {
        return this.imiModel.findAll({
            where: { ano, distrito },
            order: [['municipio', 'ASC']],
        });
    }
}
