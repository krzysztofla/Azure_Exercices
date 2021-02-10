
using System;
using System.Threading.Tasks;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;

namespace KeyVault
{
    class Program
    {
        static void Main(string[] args)
        {
            GetExampleSecretFromKVAsync().Wait();
        }

        private static async Task GetExampleSecretFromKVAsync() {
            var azureServiceTokenProvider = new AzureServiceTokenProvider();
            var kvc = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback));
            
            var kvBaseUrl = "https://hermesexamplekv.vault.azure.net/";
            var secret = await kvc.GetSecretAsync(kvBaseUrl, "connectionString");
            Console.WriteLine(secret);
        }
    }
}
