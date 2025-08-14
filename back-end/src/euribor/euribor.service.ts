import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AxiosError } from 'axios';

@Injectable()
export class EuriborService {
  private readonly baseUrl = 'https://www.euribor-rates.eu/umbraco/api/euriborpageapi/highchartsdata';

  constructor(private readonly httpService: HttpService) { }

  private getHeaders(withCookies = false): Record<string, string> {
    const headers: Record<string, string> = {
      accept: '*/*',
      'accept-language': 'pt-PT,pt;q=0.9,en-US;q=0.8,en;q=0.7',
      referer: 'https://www.euribor-rates.eu/en/current-euribor-rates/2/euribor-rate-3-months/',
      'sec-ch-ua': '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36',
    };

    if (withCookies) {
      headers.cookie = process.env.EURIBOR_COOKIES || ''; // You can paste cookie string here temporarily for testing
    }

    return headers;
  }

  async getEuriborData3Months() {
    const url = `${this.baseUrl}?series[0]=2`; // 3-month Euribor
    try {
      const response$ = this.httpService.get(url, {
        headers: this.getHeaders(true), // cookies required
      });
      const response = await firstValueFrom(response$);
      return { data: response.data };
    } catch (error) {
      const axiosError = error as AxiosError;
      console.error('Erro na API Euribor (3 meses):', axiosError.message);
      throw new InternalServerErrorException('Erro ao obter dados da Euribor (3 meses)');
    }
  }


  async getEuriborData() {
    return this.getDataBySeries(5);
  }

  async getEuriborData3() {
    return this.getDataBySeries(2);
  }

  async getEuriborData6() {
    return this.getDataBySeries(3);
  }

  async getEuriborData12() {
    return this.getDataBySeries(4);
  }

  private async getDataBySeries(series: number) {
    const url = `${this.baseUrl}?series[0]=${series}`;
    try {
      const response$ = this.httpService.get(url, {
        headers: this.getHeaders(series === 2), 
      });
      const response = await firstValueFrom(response$);
      return { data: response.data };
    } catch (error) {
      const axiosError = error as AxiosError;
      console.error(`Erro na API Euribor (series ${series}):`, axiosError.message);
      throw new InternalServerErrorException(`Erro ao obter dados da Euribor (series ${series})`);
    }
  }
}
