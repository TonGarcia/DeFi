// SPDX-License-Identifier: none
// File: https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Context.sol



pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// File: mint_dollar.sol


pragma solidity ^0.8.12;

//import "hardhat/console.sol";



contract MintDollar is ERC20 {
    uint8 private _decimal = 2;
    uint private _liquidationRatio = 170;
    uint private _minMintableStablecoin = 1000; // US$ 10.00
    mapping(address => Collateral[]) lockedCollateralsDB;

    modifier auth {
        require(lockedCollateralsDB[msg.sender].length > 0, "Wallet without any collaterals");
        _;
    }

    /**
      * Collateral Strcut
      * @param lockedCollateral = received ether on the transaction (ETH in WEI units)
      * @param remainingCollateral = not yet repaid, if zero it user was liquidated or got it back
      * @param vaultDebt = amount of StableCoin added to the user on the collateralization action
      * @param liquidationPrice = price which the balance gonna be liquidated
      * ratio = margin, stored to get back in time, because it liquidation ration can change along the time
    */
    struct Collateral {
        uint256 lockedCollateral;
        uint256 remainingCollateral;
        uint256 vaultDebt;
        uint liquidationPrice;
    }

    // ETH price oracle
    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Mainnet
     * Aggregator: ETH/USD
     * Dec: 8
     * Address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
     * Addresses on the networks: https://docs.chain.link/docs/ethereum-addresses/
    */
    address _mainChainlinkETHUSD = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    /**
     * Network: Rinkeby
     * Aggregator: ETH/USD
     * Dec: 8
     * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     * Addresses on the networks: https://docs.chain.link/docs/ethereum-addresses/
    */
    address _rinkebyChainlinkETHUSD = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;

    // Constructor on deploy contract: "Mint Dollar","USDM",100000
    constructor(string memory name, string memory symbol, uint _initialSupply) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender = 100 * 10**uint(decimals())
        // Mint 100.000.000 tokens to msg.sender = 100000000 * 10**uint(decimals())
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        // 100 * 10**uint(decimals()) == 100 units and 100000000000000000000 min units
        // 100000000 * 10**uint(decimals()) == 100.000.000 units and 100000000000000000000 min units
        _mint(msg.sender, _initialSupply * 10**uint(decimals()));

        //address chainlinkETHUSD = _mainChainlinkETHUSD;
        address chainlinkETHUSD = _rinkebyChainlinkETHUSD;

        // Instantiate chainlink oracle client
        priceFeed = AggregatorV3Interface(chainlinkETHUSD);
    }

    // Override the decimals to 2 decimals to look like stable coin
    function decimals() public view virtual override returns (uint8) {
        return _decimal;
    }

    /**
     * Receive the account
     * Returns all user's collaterals
    */
    function getCollateralsEthOf(address account) public view virtual auth returns(Collateral[] memory) {
        require(account == address(account),"Invalid address account");
        return lockedCollateralsDB[account];
    }

    /**
     * Receives the ether
     * Calculate the ratio
     * Store the ether on the user address
     * Mint stablecoin
     * Send the minted stablecoin to the user address
     * @param vaultDebt = how much StableCoin to be minted
    */
    function collaterallize(uint256 vaultDebt) external payable {
        // start the collateralization
        uint256 eth1 = 10 ** 18;
        uint256 lockedCollateral = msg.value;
        uint256 remainingCollateral = lockedCollateral;

        // calculate the received ETH in dollar amount
        (
            , //uint80 roundID
            int globalPrice,
            , //uint unitsPrice
            , //uint startedAt
            , //uint timeStamp
            // uint80 answeredInRound
        ) = getETHUSD(lockedCollateral);
        uint256 _globalPrice = uint256(globalPrice);

        // Check if the asked/bid value is greater than the minimal mintable stablecoin
        require(_minMintableStablecoin <= vaultDebt, "The received ETH doesn't mint the minimal amount of US$ 10.00");

        // Calculate to check if the received ether fit the vaultDebt required
        uint calcVaultDebt = (lockedCollateral * _globalPrice) / eth1; // amount to be minted
        require(_minMintableStablecoin <= calcVaultDebt, "The received ETH doesn't mint the minimal amount of US$ 10.00");
        require(calcVaultDebt >= vaultDebt, "The received ETH doesn't fit to collaterize the asked amount vaultDebt");

        // Provided Ratio = (Collateral Amount x Collateral Price) ÷ Generated Stable × 100
        uint providedRatio = calcProvidedRatio(lockedCollateral, globalPrice, vaultDebt);
        require(providedRatio >= _liquidationRatio, "The amount asked vs. paid ETH diverges for the liquidation ratio: 170%");

        // Liquidation Price = (Generated Stable * Liquidation Ratio) / (Amount of Collateral)
        uint liquidationPrice = estimateLiquidationPrice(calcVaultDebt, uint16(_globalPrice));

        // Mint the stablecoin
        _mint(msg.sender, vaultDebt);

        // Store the calculated data
        lockedCollateralsDB[msg.sender].push(
            Collateral(
                lockedCollateral,
                remainingCollateral,
                calcVaultDebt, // mintedStableCoin
                liquidationPrice
            )
        );
    }

    /**
     * Repay the user collateral burning it stable and sending back the user ether
     * @param idxCollateral is the index of the collateral on the DB for the msg.sender address 
     * @param amount is the amount in stablecoin to be refunded to unlock collateral
    */
    function repay(uint idxCollateral, uint256 amount) external auth {
        // aux vars
        // uint256 eth1 = 1 * 10**18;
        Collateral memory collateral = lockedCollateralsDB[msg.sender][idxCollateral];

        // the minimal repay it the minimal mintable
        require(_minMintableStablecoin < amount, "The received ETH doesn't mint the minimal amount of US$ 10.00");

        // calculate the remain collateral repay in dollar amount
        (
            , //uint80 roundID
            , //int ethPrice
            uint256 remainingCollateralPrice,
            , //uint startedAt
            , //uint timeStamp
            // uint80 answeredInRound
        ) = getETHUSD(collateral.remainingCollateral);

        // only fullfill repay strategy (mintedStableCoin = vaultDebt)
        string memory errorMsg = string(
                                abi.encodeWithSignature("The received amount: US$ (uint256) is less than the vaultDebt: US$ (uint256)", 
                                amount, collateral.vaultDebt)
                            );

        require(remainingCollateralPrice != amount, errorMsg);

        // burn the stablecoins
        uint256 currentBalance = balanceOf(msg.sender);
        _burn(msg.sender, amount);
        require(balanceOf(msg.sender) == (currentBalance - amount), "Unable to burn/repay");

        // refund the user ethers
        bool sent = payable(msg.sender).send(collateral.remainingCollateral);
        require(sent, "Failed to refund the account. The system was unable to send ether.");
    }

    // ##########################
    // #  CONVERTION FUNCTIONS  #
    // ##########################

    /*
     * Liquidation Ratio = (Collateral Amount x Collateral Price) ÷ Generated Stable × 100
    */
    function calcProvidedRatio(uint256 collateredEthInWei, int globalPrice, uint256 expectedStable) 
                                      public pure returns (uint providedRatio) {
        uint ethFloatPrice = uint(globalPrice/ 10**8);
        return (collateredEthInWei * ethFloatPrice) / (expectedStable * 10**12 * 100);
    }

    /*
     * vaultDebt = amount to be minted
     * currentPrice = price (1000 = US$ 10.00)
     * Liquidation Price = (Generated Stable * Liquidation Ratio) / (Amount of Collateral)
    */
    function estimateLiquidationPrice(uint256 vaultDebt, uint16 currentPrice) 
                                      public view returns (uint liquidationPrice) {
        uint256 calcLiquidationRatio = (vaultDebt*_liquidationRatio*(10**14))/currentPrice;
        return (currentPrice*calcLiquidationRatio)/(10**16); // liquidationPrice
    }

    // #######################
    // # ORACLE INTEGRATION  #
    // #######################

    /**
     * Returns the latest price
     * sample return manipulation: 307184535214 / 10**8 = US$ 3071.84
     * globalPrice = the price with the max decimals precision
     * unitsPrice = the price in stablecoin precision (2 float decimals)
     */
    function getETHUSD(uint256 amount) 
                       public view returns (
                           uint80 roundID, 
                           int256 globalPrice, 
                           uint256 unitsPrice, 
                           uint startedAt, 
                           uint timeStamp, 
                           uint80 answeredInRound) {

        // 1 ETH means 10**18 WEI
        uint eth1 = 10 ** 18;

        // if the amount is less or equals 1, so it considers 1 ETH, if it is greater than 1 it considers weis
        if(amount <= 1) {
            amount = eth1;
        }

        // retrieve the data from the oracle
        (
            roundID,
            globalPrice,
            startedAt,
            timeStamp,
            answeredInRound
        ) = priceFeed.latestRoundData();

        uint256 floatPrice = uint256(globalPrice / 10**8);

        // format the output
        return (roundID,
                globalPrice,
               ((floatPrice * amount * 100) / eth1),
               startedAt,
               timeStamp,
               answeredInRound);
    }

}
