namespace Model
{
    public class SettingsModel
    {
        public int SettingID { get; set; }
        public decimal VATRate { get; set; }
        public string DefaultLanguage { get; set; }
        public DateTime LastUpdated { get; set; }
    }
}
